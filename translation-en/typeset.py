#!/usr/bin/python3
import csv
from PIL import Image,ImagePalette
import numpy as np

#"ID","JAPANESE","PS EN","ENGLISH"
WMES_CSV = 'landmakr-script - WMES.csv'
ID_K = 'ID'
TEXT_K = 'ENGLISH'

FONT_FILE = 'font'

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
    def __init__(self, width=288, height=48):
        self.w = width
        self.h = height
        self.canvas = np.zeros((height, width), dtype=np.uint8)

    def draw_glyph(self, g: Glyph, x, y):
        self.canvas[y:(y+g.h), x:(x+g.w)] = g.glyph
        return self

    def draw_string(self, s: str, y: int, font: dict[str, Glyph], centered = True):
        last_char = None
        width = 0
        if centered:
            # do a width calculation pass and avoid copying arrays later
            for c in s:
                g = font[c]
                width += g.kern.get(last_char, 0)
                width += g.w
        x = (self.w - width) // 2 
        for c in s:
            g = font[c]
            x += g.kern.get(last_char, 0)
            self.draw_glyph(g, x, y)
            x += g.w
        return self

    def draw_multiline(self, s: str, font: dict[str, Glyph], centered = True):
        lines = s.split("\n")
        if len(lines) == 1:
            y_ofs = self.h // 2 - font[" "].h
            self.draw_string(lines[0], y_ofs, font, centered)
        elif len(lines) == 2:
            # TODO: what are the correct line spacing values??
            y_ofs = self.h // 3 + 0 - font[" "].h
            self.draw_string(lines[0], y_ofs, font, centered)
            y_ofs += self.h // 3 + 0
            self.draw_string(lines[1], y_ofs, font, centered)
        return self
            

    def outlined(self, fill: np.uint8 = 15, outline: np.uint8 = 8):
        # TODO: probably a better way to do this. at least make it a function
        out = np.zeros((self.h, self.w), dtype=np.uint8)
        shape = np.roll(self.canvas, -1, axis=0) # -1,0
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, -1, axis=1) # -1,-1
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, +1, axis=0) # 0,-1
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, +1, axis=0) # 1,-1
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, +1, axis=1) # 1,0
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, +1, axis=0) # 1,1
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, -1, axis=0) # 0,1
        np.copyto(out, shape, 'no', where=shape != 0)
        shape = np.roll(self.canvas, -1, axis=0) # -1,1
        np.copyto(out, shape, 'no', where=shape != 0)
        out = np.multiply(out, outline)

        shape = self.canvas
        shape = np.multiply(shape, fill)
        np.copyto(out, shape, 'no', where=shape != 0)
        return out
        
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


def process_wmes():
    with open(WMES_CSV, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        np.set_printoptions(threshold=np.inf)
        for row in reader:
            print(row[ID_K], row[TEXT_K])
            array = Canvas(288,48).draw_multiline(row[TEXT_K], glyphs).outlined()

            im = Image.fromarray(array, mode="P")
            #im = im.transpose(method=2)
            im.putpalette(palettedata)
            im.save(f'{row[ID_K]}.png')


glyphs = {}
palettedata = [0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
               80,40,128, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 248,248,248]
if __name__ == '__main__':
    
    load_font(FONT_FILE, glyphs)

    
    process_wmes() 
