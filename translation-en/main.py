import config as cfg
import generate_tiles as tilegen
import typeset
import os


if __name__ == '__main__':
    os.system('rm tables.S')
    os.system(f'cp {cfg.SCR_HI} {cfg.SCR_HI_OUT}')
    os.system(f'cp {cfg.SCR_LO} {cfg.SCR_LO_OUT}')    
    os.system(f'cp {cfg.OBJ_HI} {cfg.OBJ_HI_OUT}')
    os.system(f'cp {cfg.OBJ_LO} {cfg.OBJ_LO_OUT}')
    tile_ids = tilegen.TileIdIterator(cfg.SCR_SAFE_TILES)
    tilegen.process_bitmaps(typeset.get_wmes(),
                    tile_ids,
                    is_scr=True,
                    full=True)
    tilegen.process_bitmaps(typeset.get_emes(),
                    tile_ids,
                    is_scr=True,
                    full=True)
