landmakr_obj_hi_romfiles = e61-01.04
landmakr_obj_lo_romfiles = e61-03.12 e61-02.08
landmakr_scr_hi_romfiles = e61-07.43
landmakr_scr_lo_romfiles = e61-09.47 e61-08.45
landmakrj_program_romfiles = e61-13.20 e61-12.19 e61-11.18 e61-10.17
landmakr_program_romfiles = e61-19.20 e61-18.19 e61-17.18 e61-16.17

ROMDIR = ../roms
OUTDIR = out
IPSDIR = ips
SRC = patch.S
AS = asl
ASFLAGS=-i . -i .. -n -U -q -l +t 70 -r 1
P2BIN = p2bin
ZIP = zip
IPS = uips c
INTERLEAVE = ../util/interleave.rb
DEINTERLEAVE = ../util/deinterleave.rb
TARGETS = landmakr landmakrj gfx_patched

.PHONY: landmakr landmakrj ips landmakr_ips landmakrj_ips gfx_patched gfx_out
.PRECIOUS: %_program_patched.bin

all: $(TARGETS)

LANDMAKRJ_OUT_PRG_ROMFILES = $(addprefix $(OUTDIR)/landmakrj/,$(landmakrj_program_romfiles))
LANDMAKR_OUT_PRG_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(landmakr_program_romfiles))
LANDMAKRJ_OUT_PRG_IPSFILES = $(addsuffix .ips,$(addprefix $(IPSDIR)/landmakrj/,$(landmakrj_program_romfiles)))
LANDMAKR_OUT_PRG_IPSFILES = $(addsuffix .ips,$(addprefix $(IPSDIR)/landmakr/,$(landmakr_program_romfiles)))
# necessary?
ALL_GFX_ROMFILES = $(landmakr_obj_hi_romfiles) $(landmakr_obj_lo_romfiles) $(landmakr_scr_hi_romfiles) $(landmakr_scr_lo_romfiles)
LANDMAKR_OUT_GFX_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(ALL_GFX_ROMFILES))
LANDMAKR_OUT_GFX_IPSFILES = $(addsuffix .ips,$(addprefix $(IPSDIR)/landmakr/,$(ALL_GFX_ROMFILES)))
LANDMAKR_OUT_OBJ_LO_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(landmakr_obj_lo_romfiles))
LANDMAKR_OUT_SCR_LO_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(landmakr_scr_lo_romfiles))
LANDMAKR_OUT_OBJ_HI_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(landmakr_obj_hi_romfiles))
LANDMAKR_OUT_SCR_HI_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(landmakr_scr_hi_romfiles))

LANDMAKRJ_OUT_ROMFILES = $(LANDMAKRJ_OUT_PRG_ROMFILES)
LANDMAKR_OUT_ROMFILES = $(LANDMAKR_OUT_PRG_ROMFILES) $(LANDMAKR_OUT_GFX_ROMFILES)
LANDMAKRJ_OUT_IPSFILES = $(LANDMAKRJ_OUT_PRG_IPSFILES)
LANDMAKR_OUT_IPSFILES = $(LANDMAKR_OUT_PRG_IPSFILES) $(LANDMAKR_OUT_GFX_IPSFILES)
landmakr: $(LANDMAKR_OUT_ROMFILES)
landmakrj: $(LANDMAKRJ_OUT_ROMFILES)
ips: landmakr_ips landmakrj_ips

landmakr_ips: landmakr $(IPSDIR)/landmakr/ $(LANDMAKR_OUT_IPSFILES)
landmakrj_ips: landmakrj $(IPSDIR)/landmakrj/ $(LANDMAKRJ_OUT_IPSFILES)

$(LANDMAKR_OUT_PRG_ROMFILES): $(OUTDIR)/landmakr/ landmakr_program_patched.bin
	$(DEINTERLEAVE) -i landmakr_program_patched.bin -o $(LANDMAKR_OUT_PRG_ROMFILES)
$(LANDMAKRJ_OUT_PRG_ROMFILES): $(OUTDIR)/landmakrj/ landmakrj_program_patched.bin
	$(DEINTERLEAVE) -i landmakrj_program_patched.bin -o $(LANDMAKRJ_OUT_PRG_ROMFILES)

$(LANDMAKR_OUT_OBJ_LO_ROMFILES): $(OUTDIR)/landmakr/ gfx_patched obj_lo_gfx_patched.bin
	$(DEINTERLEAVE) -i obj_lo_gfx_patched.bin -o $(LANDMAKR_OUT_OBJ_LO_ROMFILES)
$(LANDMAKR_OUT_SCR_LO_ROMFILES): $(OUTDIR)/landmakr/ gfx_patched scr_lo_gfx_patched.bin
	$(DEINTERLEAVE) -w 2 -i scr_lo_gfx_patched.bin -o $(LANDMAKR_OUT_SCR_LO_ROMFILES)
$(LANDMAKR_OUT_OBJ_HI_ROMFILES): $(OUTDIR)/landmakr/ gfx_patched obj_hi_gfx_patched.bin 
	cp obj_hi_gfx_patched.bin $(LANDMAKR_OUT_OBJ_HI_ROMFILES)
$(LANDMAKR_OUT_SCR_HI_ROMFILES): $(OUTDIR)/landmakr/ gfx_patched scr_hi_gfx_patched.bin 
	cp scr_hi_gfx_patched.bin $(LANDMAKR_OUT_SCR_HI_ROMFILES)


$(IPSDIR)/%/:
	mkdir -p $@
$(IPSDIR)/landmakrj/%.ips: $(ROMDIR)/landmakrj/% $(OUTDIR)/landmakrj/%
	$(IPS) $@ $^
$(IPSDIR)/landmakr/%.ips: $(ROMDIR)/landmakr/% $(OUTDIR)/landmakr/%
	$(IPS) $@ $^

$(ROMDIR)/%/: $(ROMDIR)/%.zip
	unzip $< -d $@

%_program.bin: $(ROMDIR)/%/
	$(INTERLEAVE) -i $(addprefix $<,$($*_program_romfiles)) -o $@

obj_lo_gfx.bin: $(ROMDIR)/landmakr/
	$(INTERLEAVE) -i $(addprefix $<,$(landmakr_obj_lo_romfiles)) -o $@
scr_lo_gfx.bin: $(ROMDIR)/landmakr/
	$(INTERLEAVE) -w 2 -i $(addprefix $<,$(landmakr_scr_lo_romfiles)) -o $@
%_hi_gfx.bin: $(ROMDIR)/landmakr/
	$(INTERLEAVE) -i $(addprefix $<,$(landmakr_$*_hi_romfiles)) -o $@

%_program_patched.o: %_program.bin $(SRC)
	$(AS) $(SRC) -D $* $(ASFLAGS) -o $@

%_program_patched.bin: %_program_patched.o
	$(P2BIN) $< $@ -r 0x0-0x1FFFFF

# python goes here !
gfx_patched: obj_lo_gfx.bin obj_hi_gfx.bin scr_lo_gfx.bin scr_hi_gfx.bin
	python3 main.py
#	python3 copy_kariwaku_tiles.py

$(OUTDIR)/%/: $(ROMDIR)/%
	mkdir -p $@
	cp -uprt $@ $</*

clean:
	@-rm -r $(OUTDIR)
	@-rm *.o
	@-rm *.bin

