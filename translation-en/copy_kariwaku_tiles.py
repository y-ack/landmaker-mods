from gfxrom import *

if __name__ == '__main__':
    with GfxRomWriter(cfg.SCR_LO_OUT, cfg.SCR_HI_OUT, is_scr = True) as writer:
        with GfxRomReader(cfg.OBJ_LO_OUT, cfg.OBJ_HI_OUT, is_scr = False) as reader:
            for tidx in range(0xe5a, 0xe96):
                t = reader.read_tile(tidx)
                writer.write_tile(tidx - 0xe5a + 0x7fff - 59, t)