from os import makedirs
"""The main config file for the typesetting pipeline"""

# tile chip dimensions, always 16 for Taito F3
TILE_W = 16
TILE_H = 16 # unused?

def use_path(path):
    makedirs(path, exist_ok=True)
    return path


ARRAY_OUT = use_path('intermediate/array')
PNG_OUT = use_path('intermediate/png')

# Important settings that vary by game
# tilemap rom tiles we want to overwrite
#SCR_SAFE_TILES = [(0x168, 0x293), (0x294, 0x359), (0x35b, 0x3b0), (0x789e, 0x7fff)]
SCR_SAFE_TILES = [(0x789e, 0x7fff)]
# sprite rom tiles we want to overwrite
OBJ_SAFE_TILES = [(0x6d60, 0x7fff)]

FONT_FILE = 'font.json'
# palette for previews - we probably need an address later
PALETTE = [0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
           80,40,128, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 248,248,248]
# palette indexes to use as foreground and background/outline
FG_IDX = 15
BG_IDX = 8

# CSV path and keys to use
#"ID","JAPANESE","PS EN","ENGLISH"
WMES_CSV = 'landmakr-script - WMES.csv'
EMES_CSV = 'landmakr-script - EMES.csv'
ID_K = 'ID'
TEXT_K = 'ENGLISH'

BLDEF_SUFFIX = "_EN"

# don't use these, use the interleaved versions
ROM_OBJ_LO = ["e61-03.12", "e61-02.08"]
ROM_OBJ_HI = "e61-01.04"
ROM_SCR_LO = ["e61-09.47", "e61-08.45"]
ROM_SCR_HI = "e61-07.43"

# interleaved graphics data input files
OBJ_LO = 'obj_lo_gfx.bin'
OBJ_HI = 'obj_hi_gfx.bin'
SCR_LO = 'scr_lo_gfx.bin'
SCR_HI = 'scr_hi_gfx.bin'
# output filenames
OBJ_LO_OUT = 'obj_lo_gfx_patched.bin'
OBJ_HI_OUT = 'obj_hi_gfx_patched.bin'
SCR_LO_OUT = 'scr_lo_gfx_patched.bin'
SCR_HI_OUT = 'scr_hi_gfx_patched.bin'
