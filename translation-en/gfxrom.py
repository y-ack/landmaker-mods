import config as cfg
import numpy as np
import os
#if is_tilemap then
# xflip   = (sp & 0x40000000) ~= 0
# yflip   = (sp & 0x80000000) ~= 0
# indexq  = (sp & 0x30000000) ~= 0
# planes  = (sp & 0x0c000000) >> 26
# ablend  = (sp & 0x02000000) ~= 0
# chip    = (sp & 0xffff)
#else
# xflip   = (sp & 0x01000000) ~= 0
# yflip   = (sp & 0x02000000) ~= 0
# indexq  = (sp & 0x0c000000) ~= 0
# planes  = (sp & 0x30000000) >> 28 --(?)
# ablend  = (sp & 0x40000000) ~= 0  --(?)
# chip    = (sp & 0xffff)

# different graphics roms have different encodings! ouch!
obj_xoffsets_hi = [  6,  4,  2,  0,  14, 12, 10,  8,
                    22, 20, 18, 16,  30, 28, 26, 24]
obj_planeoffsets_hi = [0, 1]
scr_xoffsets_hi = [  7,  6,  5,  4,  3,  2,  1,  0,
                    23, 22, 21, 20, 19, 18, 17, 16]
scr_planeoffsets_hi = [8, 0]

class GfxRomWriter(object):
    def __init__(self, lo, hi, is_scr: bool):
        self.gfx_lo = lo
        self.gfx_hi = hi
        self.is_scr = is_scr
        if is_scr:
            self.planeoffsets_hi = scr_planeoffsets_hi
            self.xoffsets_hi = scr_xoffsets_hi
        else:
            self.planeoffsets_hi = obj_planeoffsets_hi
            self.xoffsets_hi = obj_xoffsets_hi
            
    def __enter__(self):
        self.fp_hi = np.fromfile(self.gfx_hi, dtype=">I")
        self.fp_lo = np.fromfile(self.gfx_lo, dtype="B")
        return self

    def __exit__(self, *exc):
        self.fp_hi.tofile(self.gfx_hi)
        self.fp_lo.tofile(self.gfx_lo)
        return False

    @staticmethod
    def split_color(color) -> (int, int, int):
        color_lo   = color & 0b001111
        color_hi_0 = (color & 0b010000) >> 4
        color_hi_1 = (color & 0b100000) >> 5
        return color_lo, color_hi_0, color_hi_1
        
    def write_row(self, tile_id, y, colors: np.ndarray):
        """set the row y within the tile `tile_id` to the specified
        colors."""
        assert colors.shape == (16,), "color array must be a single tile row (16 values)"
        lo_ofs = (256*tile_id + y*16) // 2 # 2 px per byte low rom
        hi_ofs = (256*tile_id + y*16) // 16 # 4 px per byte high rom (sort of)
        hi_acc = 0
        for x in range(0, 16, 2):
            c1_lo, *c1_hi = self.split_color(colors[x])
            c2_lo, *c2_hi = self.split_color(colors[x+1])
            # 22221111
            self.fp_lo[lo_ofs + (x // 2)] = c2_lo << 4 | c1_lo
            hi_acc |= (c1_hi[0] << self.xoffsets_hi[x]) << self.planeoffsets_hi[0]
            hi_acc |= (c1_hi[1] << self.xoffsets_hi[x]) << self.planeoffsets_hi[1]
            hi_acc |= (c2_hi[0] << self.xoffsets_hi[x+1]) << self.planeoffsets_hi[0]
            hi_acc |= (c2_hi[1] << self.xoffsets_hi[x+1]) << self.planeoffsets_hi[1]
        self.fp_hi[hi_ofs] = hi_acc

    def write_tile(self, tile_id, tile_data: np.ndarray):
        for y in range (0, 16):
            self.write_row(tile_id, y, tile_data[y,:])

class GfxRomReader(object):
    def __init__(self, lo, hi, is_scr: bool):
        self.gfx_lo = lo
        self.gfx_hi = hi
        self.is_scr = is_scr
        if is_scr:
            self.planeoffsets_hi = scr_planeoffsets_hi
            self.xoffsets_hi = scr_xoffsets_hi
        else:
            self.planeoffsets_hi = obj_planeoffsets_hi
            self.xoffsets_hi = obj_xoffsets_hi
            
    def __enter__(self):
        self.fp_hi = np.fromfile(self.gfx_hi, dtype=">I")
        self.fp_lo = np.fromfile(self.gfx_lo, dtype="B")
        return self

    def __exit__(self, *exc):
        return False

    @staticmethod
    def merge_color(lo, hi_0, hi_1) -> (int):
        return lo | hi_0 << 4 | hi_1 << 5
        
    def read_row(self, tile_id, y) -> np.ndarray:
        """get the row y within the tile `tile_id`"""
        colors = np.empty((16,), dtype="B")
        lo_ofs = (256*tile_id + y*16) // 2 # 2 px per byte low rom
        hi_ofs = (256*tile_id + y*16) // 16 # 4 px per byte high rom (sort of)
        c_hi = self.fp_hi[hi_ofs]
        for x in range(0, 16, 2):
            # 22221111
            c_lo = self.fp_lo[lo_ofs + x // 2]
            c1_lo = c_lo & 0b1111
            c2_lo = c_lo >> 4
            c1_hi0 = c_hi >> self.xoffsets_hi[x] >> self.planeoffsets_hi[0] & 1
            c1_hi1 = c_hi >> self.xoffsets_hi[x] >> self.planeoffsets_hi[1] & 1
            c2_hi0 = c_hi >> self.xoffsets_hi[x+1] >> self.planeoffsets_hi[0] & 1
            c2_hi1 = c_hi >> self.xoffsets_hi[x+1] >> self.planeoffsets_hi[1] & 1
            colors[x] = self.merge_color(c1_lo, c1_hi0, c1_hi1)
            colors[x+1] = self.merge_color(c2_lo, c2_hi0, c2_hi1)
        return colors

    def read_tile(self, tile_id) -> np.ndarray:
        tile_data = np.empty((16,16), dtype="B")
        for y in range (0, 16):
            tile_data[y] = self.read_row(tile_id, y)
        return tile_data

# test routine
if __name__ == '__main__':
    os.system(f'cp {cfg.SCR_HI} {cfg.SCR_HI_OUT}')
    os.system(f'cp {cfg.SCR_LO} {cfg.SCR_LO_OUT}')    
    os.system(f'cp {cfg.OBJ_HI} {cfg.OBJ_HI_OUT}')
    os.system(f'cp {cfg.OBJ_LO} {cfg.OBJ_LO_OUT}')
    test_tile = np.arange(256).reshape((16,16))
    with GfxRomWriter(cfg.OBJ_LO_OUT, cfg.OBJ_HI_OUT, is_scr = False) as gfxrom:
        for i in range(0,0x1FFF):
            gfxrom.write_tile(i, test_tile)

    with GfxRomWriter(cfg.SCR_LO_OUT, cfg.SCR_HI_OUT, is_scr = True) as gfxrom:
        for i in range(0,0x1FFF):
            gfxrom.write_tile(i, test_tile)
