import typeset
import numpy as np

chips = {}

SCR_SAFE_TILES = [(0x168, 0x293), (0x294, 0x3b0), (0x789e, 0xffff)]
OBJ_SAFE_TILES = [(0x6d60, 0x7fff)]

class TileIdIterator:
    """iterator over known safe tile id ranges"""
    def __init__(self, tile_ranges: list[tuple]):
        self.total_used = 0
        self.cur_block = 0
        self.safe_blocks = tile_ranges
        self.cur_id = self.safe_blocks[self.cur_block][0]
        
    def __next__(self):
        if self.cur_id > self.safe_blocks[self.cur_block][1]:
            self.cur_block += 1
            if self.cur_block > len(self.safe_blocks):
                raise IndexError(f"out of safe tile ids (last: {self.safe_blocks[self.cur_block-1]})")
            self.cur_id = self.safe_blocks[self.cur_block][0]
        self.cur_id += 1
        self.total_used += 1
        return self.cur_id
    
    def __iter__(self):
        return self
   

# useless?
class TileChip:
    # 16x16
    def __init__(self, bitmap: np.ndarray):
        """bitmap must be dtype=uint8"""
        self.bitmap = bitmap
        
    def is_empty(self):
        return np.amax(this.bitmap, initial = 0) == 0


def process_bitmaps():
    # WMES
    TILE_W = 16
    obj_ids = TileIdIterator(OBJ_SAFE_TILES)
    tile_ids = {}
    tile_ids[np.zeros((16,TILE_W), dtype=np.uint8).tostring()] = 0
    for cnv in typeset.get_wmes():
        # skip rows, pretend generating sprite strips?
        for y in cnv.line_ofs:
            for x in range(0, cnv.w, TILE_W):
                tile = cnv.get_tile(x, y, TILE_W, 16)
                #print(tile)
                if tile.tobytes() not in tile_ids:
                    tile_ids[tile.tobytes()] = next(obj_ids)

                print(f"{tile_ids[tile.tobytes()]:X},", end="")
            print()
    print(f"chips used: {obj_ids.total_used}")

# known tile chips
chips = {}
if __name__ == '__main__':
    process_bitmaps()
