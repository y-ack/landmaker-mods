import config as cfg
import gfxrom
import typeset
import table_writer
import numpy as np
import os

chips = {}

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
        n = self.cur_id
        self.cur_id += 1
        self.total_used += 1
        return n
    
    def __iter__(self):
        return self
   
def process_bitmaps(canvas_gen, safe_tiles: TileIdIterator, is_scr, full = True):
    """process 2d numpy array bitmaps provided by the generator `canvas_gen`
    into 16x16 tiles, assigning to tile ids as provided by `safe_tiles`.
    if `full` (optional) is False, use the line offsets on the canvas to
    generate optimized strips. if `full` is True, the rows start at y=0 and
    cover the full canvas."""
    lo, hi = (cfg.SCR_LO_OUT,cfg.SCR_HI_OUT) if is_scr else (cfg.OBJ_LO_OUT,cfg.OBJ_HI_OUT)
    with gfxrom.GfxRomWriter(lo, hi, is_scr=is_scr) as rom:
        # basic tile id map setup
        tile_ids = {}
        tile_ids[np.zeros((cfg.TILE_H, cfg.TILE_W), dtype=np.uint8).tostring()] = 0

        # setup for the indirection tables
        # TODO: where should this name be coming from??
        #mestbl = table_writer.MesInfo(r"_BL_(.MES[A-Z])01")

        # handle all canvases
        for cnv, bl_id in canvas_gen:
            table_file = "tables-wmes.s" if ("WMES" in bl_id) else "tables-emes.s"
            # skip rows, pretend generating sprite strips?
            rows = range(0, cnv.h, cfg.TILE_H) if full else cnv.line_ofs
            cols = range(0, cnv.w, cfg.TILE_W)
            # SCR block defs are column-major, affects tile processing order
            
            # what kind of block defs? split or whole?
            # TODO: THIS IS   BAD   ASSUMES OBJ/SCR THINGS
            bl = []
            if full:
                bl.append(table_writer.BlockDef(bl_id + cfg.BLDEF_SUFFIX +
                                                str(0), len(rows), len(cols),
                                                is_scr))
                #mestbl.new_message(bl_id, 1)
            else:
                for y in rows:
                    bl.append(table_writer.BlockDef(bl_id + cfg.BLDEF_SUFFIX +
                                                    str(y), 0, len(cols) - 1,
                                                    is_scr))
                #mestbl.new_message(bl_id, len(rows))

            if not is_scr: rows,cols = cols,rows
            for y in rows:
                bl[0].new_line()
                #mestbl.add_strip(bl_id + cfg.BLDEF_SUFFIX + str(y), y)
                
                for x in cols:
                    if is_scr:
                        tile = cnv.get_tile(x, y, cfg.TILE_W, cfg.TILE_H)
                    else:
                        tile = cnv.get_tile(y, x, cfg.TILE_W, cfg.TILE_H)

                    if tile.tobytes() not in tile_ids:
                        idx = tile_ids[tile.tobytes()] = next(safe_tiles)
                        # new tile to write!
                        rom.write_tile(idx, tile)

                    bl[0].write_chip(tile_ids[tile.tobytes()])
                # pop the block def if separate tables per line
                if not full:
                    bl[0].finalize()
                    bl[0].save(table_file)
                    bl = bl[1:]
            if full:
                bl[0].finalize()
                bl[0].save(table_file)

    # ALL block defs should be written at this point.
    # we now write the accumulated strip data table and pointer tables
    #mestbl.save("tables.S")
    print(f"chips used: {safe_tiles.total_used}")



# known tile chips
chips = {}
if __name__ == '__main__':
    os.system('rm tables.S')
    os.system(f'cp {cfg.SCR_HI} {cfg.SCR_HI_OUT}')
    os.system(f'cp {cfg.SCR_LO} {cfg.SCR_LO_OUT}')    
    os.system(f'cp {cfg.OBJ_HI} {cfg.OBJ_HI_OUT}')
    os.system(f'cp {cfg.OBJ_LO} {cfg.OBJ_LO_OUT}')
    process_bitmaps(typeset.get_wmes(),
                    TileIdIterator(cfg.OBJ_SAFE_TILES),
                    is_scr=False,
                    full=False)
    process_bitmaps(typeset.get_emes(),
                    TileIdIterator(cfg.SCR_SAFE_TILES),
                    is_scr=True,
                    full=True)
