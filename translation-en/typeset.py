#!/usr/bin/python3
import config as cfg
import csv
import json
from PIL import Image,ImagePalette
import numpy as np
import re

class Glyph:
    def __init__(self, glyphbitmap, width=0, hidth=14, lsb=0, advance=0, kern: dict[str,int]={}):
        self.glyph = glyphbitmap
        self.w = width
        self.h = hidth
        self.lsb = lsb
        self.advance = advance
        self.kern = kern

    def from_col_bits(self, bitmap: list[list[int]]):
        self.glyph = np.rot90(np.unpackbits(bitmap,axis=1,count=self.h,bitorder='little'))

        
def load_font(filename=cfg.FONT_FILE, glyphs_dict={}):
    with open(filename, newline='') as fontfile:
        glyphdata = json.load(fontfile)
    # populate the glyph map with pre-processed glyph bitmaps
    for gd in glyphdata.values():
        g = Glyph(None, len(gd['cols']), 14, gd['lsb'], gd['advance'], gd['kern'])
        # coerce column data into uint8 lists suitable for numpy.unpackbits
        columns = [[int(i) & 0xff,int(i)>>8] for i in gd['cols']]
        g.from_col_bits(np.array(columns, dtype=np.uint8))
        glyphs_dict[gd['char']] = g


class Canvas:
    def __init__(self, width=288, height=48):
        self.w = width
        self.h = height
        self.canvas = np.zeros((height, width), dtype=np.uint8)
        self.line_ofs = []

    def draw_glyph(self, g: Glyph, x, y):
        self.canvas[y:(y+g.h), x:(x+g.w)][g.glyph != 0] = g.glyph[g.glyph != 0]
        return self

    def draw_string(self, s: str, y: int, font: dict[str, Glyph], centered = True):
        # record y offsets for tile generation
        self.line_ofs.append(y)
        last_char = None
        g = None
        width = 0
        if centered:
            # do a width calculation pass and avoid copying arrays later
            for c in s:
                g = font[c]
                width += g.lsb
                width += g.kern.get(last_char, 0)
                width += g.advance
                width += 1
                last_char = c
            if g:
                # adjust for extra whitespace at end of line
                width -= g.advance - g.glyph.shape[1]

        last_char = None
        x = (self.w - width) // 2 
        for c in s:
            g = font[c]
            x += g.lsb
            x += g.kern.get(last_char, 0)
            self.draw_glyph(g, x, y)
            x += g.advance
            x += 1
            last_char = c
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

    def outlined(self, fill: np.uint8 = cfg.FG_IDX, outline: np.uint8 = cfg.BG_IDX):
        out = np.zeros((self.h, self.w), dtype=np.uint8)
        # draw the outline shape, starting at -1,0
        shape = np.roll(self.canvas, -1, axis=0)
        out[shape != 0] = shape[shape != 0]
        
        for d,ax in ((-1,1), (+1,0), (+1,0), (+1,1), (+1,1), (-1,0), (-1,0)):
            shape = np.roll(shape, d, axis=ax)
            out[shape != 0] = shape[shape != 0]
        out = np.multiply(out, outline)

        shape = self.canvas
        shape = np.multiply(shape, fill)
        np.copyto(out, shape, 'no', where=shape != 0)
        return out

    def draw_outline(self, fill: np.uint8 = cfg.FG_IDX, outline: np.uint8 = cfg.BG_IDX):
        self.canvas = self.outlined(fill, outline)
        return self

    def save_file(self, outfile):
        np.save(outfile, self.canvas, allow_pickle = False)

    def save_png(self, outfile, palette = cfg.PALETTE):
            im = Image.fromarray(self.canvas, mode="P")
            #im = im.transpose(method=2)
            im.putpalette(palette)
            im.save(outfile)

    def get_tile(self, x, y, w, h):
        return self.canvas[y:(y+h), x:(x+w)]
            
    def data(self):
        return self.canvas

def get_mes(mes_csv):
    """wmes bitmap generator"""
    with open(mes_csv, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        np.set_printoptions(threshold=np.inf)
        for row in reader:
            # replace opening quotation marks with U+2C01
            text = re.sub(r'"(?sm)(.*)"', r'“\1"', row[cfg.TEXT_K])
            print(row[cfg.ID_K], text)
            c = Canvas(288,48).draw_multiline(text, glyphs).draw_outline()
            yield c, row[cfg.ID_K]

def get_wmes(wmes_csv=cfg.WMES_CSV):
    """wmes bitmap generator"""
    return get_mes(mes_csv=wmes_csv)

def get_emes(emes_csv=cfg.EMES_CSV):
    """wmes bitmap generator"""
    return get_mes(mes_csv=emes_csv)

def debug_save_mes(get_mes_fn):
    for c, mes_id in get_mes_fn:
        c.save_png(f'{cfg.PNG_OUT}/{mes_id}.png', cfg.PALETTE)
        c.save_file(f'{cfg.ARRAY_OUT}/{mes_id}')

def debug_save_wmes():
    for c, mes_id in get_wmes():
        c.save_png(f'{cfg.PNG_OUT}/{mes_id}.png', cfg.PALETTE)
        c.save_file(f'{cfg.ARRAY_OUT}/{mes_id}')

# TODO: eliminate global glyph map
glyphs = {}
load_font(cfg.FONT_FILE, glyphs)
if __name__ == '__main__':
    debug_save_mes(get_wmes())
    debug_save_mes(get_emes())
