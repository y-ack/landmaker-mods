#!/usr/bin/python3
import csv
from PIL import Image,ImagePalette
import numpy as np

#"ID","JAPANESE","PS EN","ENGLISH"
WMES_CSV = 'landmakr-script - WMES.csv'
ID_K = 'ID'
TEXT_K = 'ENGLISH'

FONT_FILE = 'font'

OUT_DIR = 'intermediate/wmes_array'
PNG_OUT_DIR = 'intermediate/wmes_png'

class Glyph:
    def __init__(self, glyphbitmap, width=0, hidth=14, kern: dict[str,int]={}):
        self.glyph = glyphbitmap
        self.w = width
        self.h = hidth
        self.kern = kern
        
    def from_col_bits(self, bitmap: list[list[int]]):
        #self.glyph = np.unpackbits(bitmap,axis=1,count=self.h,bitorder='little')
        self.glyph = np.rot90(np.unpackbits(bitmap,axis=1,count=self.h,bitorder='little'))


class Canvas:
    palettedata = [0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
                   80,40,128, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 248,248,248]

    def __init__(self, width=288, height=48):
        self.w = width
        self.h = height
        self.canvas = np.zeros((height, width), dtype=np.uint8)
        self.line_ofs = []

    def draw_glyph(self, g: Glyph, x, y):
        self.canvas[y:(y+g.h), x:(x+g.w)] = g.glyph
        return self

    def draw_string(self, s: str, y: int, font: dict[str, Glyph], centered = True):
        # record y offsets for tile generation
        self.line_ofs.append(y)
        last_char = None
        width = 0
        if centered:
            # do a width calculation pass and avoid copying arrays later
            for c in s:
                g = font[c]
                width += g.kern.get(last_char, 0)
                width += g.w + 1 # TODO +1 hack before width data
        x = (self.w - width) // 2 
        for c in s:
            g = font[c]
            x += g.kern.get(last_char, 0)
            self.draw_glyph(g, x, y)
            x += g.w + 1 # TODO
        return self

    def draw_multiline(self, s: str, font: dict[str, Glyph], centered = True):
        lines = s.split("\n")
        if len(lines) == 1:
            y_ofs = self.h // 2 - font[" "].h // 2
            self.draw_string(lines[0], y_ofs, font, centered)
        elif len(lines) == 2:
            # TODO: what are the correct line spacing values??
            y_ofs = 6 # self.h // 3 + 0 - font[" "].h
            self.draw_string(lines[0], y_ofs, font, centered)
            y_ofs += 14 + 4 # self.h // 3 + 0
            self.draw_string(lines[1], y_ofs, font, centered)
        return self
            

    def outlined(self, fill: np.uint8 = 15, outline: np.uint8 = 8):
        # TODO: probably a better way to do this. at least make it a function
        out = np.zeros((self.h, self.w), dtype=np.uint8)
        shape = np.roll(self.canvas, -1, axis=0) # -1,0
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, -1, axis=1) # -1,-1
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, +1, axis=0) # 0,-1
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, +1, axis=0) # 1,-1
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, +1, axis=1) # 1,0
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, +1, axis=1) # 1,1
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, -1, axis=0) # 0,1
        out[shape != 0] = shape[shape != 0]
        shape = np.roll(shape, -1, axis=0) # -1,1
        out[shape != 0] = shape[shape != 0]
        out = np.multiply(out, outline)

        shape = self.canvas
        shape = np.multiply(shape, fill)
        np.copyto(out, shape, 'no', where=shape != 0)
        return out

    def draw_outline(self, fill: np.uint8 = 15, outline: np.uint8 = 8):
        self.canvas = self.outlined(fill, outline)
        return self

    def save_file(self, outfile):
        np.save(outfile, self.canvas, allow_pickle = False)

    def save_png(self, outfile, palette = palettedata):
            im = Image.fromarray(self.canvas, mode="P")
            #im = im.transpose(method=2)
            im.putpalette(palette)
            im.save(outfile)

    def get_tile(self, x, y, w, h):
        return self.canvas[y:(y+h), x:(x+w)]
            
    def data(self):
        return self.canvas

        
def load_font(filename=FONT_FILE, glyphs_dict={}):
    with open(filename, newline='') as fontfile:
        # FIXME: pending actual space glyph in font data
        glyphs_dict[" "] = Glyph(np.zeros((14,3), dtype=np.uint8), 3, 14)

        # FIXME: new data format should specify char
        for i, gd in enumerate(fontfile):
            columns = [[int(i) & 0xff,int(i)>>8] for i in gd.split(",")]
            g = Glyph(None, len(columns), 14)
            g.from_col_bits(np.array(columns, dtype=np.uint8))
            glyphs_dict[chr(i+0x21)] = g


def get_wmes(wmes_csv=WMES_CSV):
    """wmes bitmap generator"""
    with open(wmes_csv, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        np.set_printoptions(threshold=np.inf)
        for row in reader:
            print(row[ID_K], row[TEXT_K])
            c = Canvas(288,48).draw_multiline(row[TEXT_K], glyphs).draw_outline()
            yield c

def debug_save_wmes():
    for c in get_wmes():
        c.save_png(f'{PNG_OUT_DIR}/{row[ID_K]}.png')
        c.save_file(f'{OUT_DIR}/{row[ID_K]}')

# TODO: eliminate global glyph map
glyphs = {}
load_font(FONT_FILE, glyphs)
if __name__ == '__main__':
    debug_save_wmes()
