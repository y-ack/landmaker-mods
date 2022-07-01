landmakrj_program_romfiles = e61-13.20 e61-12.19 e61-11.18 e61-10.17
landmakr_program_romfiles = e61-19.20 e61-18.19 e61-17.18 e61-16.17

ROMDIR = ../roms
OUTDIR = out
IPSDIR = ips
SRC = patch.S
AS = asl
ASFLAGS=-i . -i .. -n -U -q
P2BIN = p2bin
ZIP = zip
IPS = uips c
INTERLEAVE = ../util/interleave.rb
DEINTERLEAVE = ../util/deinterleave.rb
TARGETS = landmakr landmakrj

.PHONY: landmakr landmakrj ips landmakr_ips landmakrj_ips
.PRECIOUS: %_program.bin

all: $(TARGETS)

LANDMAKRJ_OUT_ROMFILES = $(addprefix $(OUTDIR)/landmakrj/,$(landmakrj_program_romfiles))
LANDMAKR_OUT_ROMFILES = $(addprefix $(OUTDIR)/landmakr/,$(landmakr_program_romfiles))
LANDMAKRJ_OUT_IPSFILES = $(addsuffix .ips,$(addprefix $(IPSDIR)/landmakrj/,$(landmakrj_program_romfiles)))
LANDMAKR_OUT_IPSFILES = $(addsuffix .ips,$(addprefix $(IPSDIR)/landmakr/,$(landmakr_program_romfiles)))
landmakr: $(LANDMAKR_OUT_ROMFILES)
landmakrj: $(LANDMAKRJ_OUT_ROMFILES)
ips: landmakr_ips landmakrj_ips

landmakr_ips: landmakr $(IPSDIR)/landmakr/ $(LANDMAKR_OUT_IPSFILES)
landmakrj_ips: landmakrj $(IPSDIR)/landmakrj/ $(LANDMAKRJ_OUT_IPSFILES)

$(LANDMAKR_OUT_ROMFILES): $(OUTDIR)/landmakr/ landmakr_patched.bin
	$(DEINTERLEAVE) -i landmakr_patched.bin -o $(LANDMAKR_OUT_ROMFILES)
$(LANDMAKRJ_OUT_ROMFILES): $(OUTDIR)/landmakrj/ landmakrj_patched.bin
	$(DEINTERLEAVE) -i landmakrj_patched.bin -o $(LANDMAKRJ_OUT_ROMFILES)

$(IPSDIR)/%/:
	mkdir -p $@
$(IPSDIR)/landmakrj/%.ips: $(OUTDIR)/landmakrj/% $(ROMDIR)/landmakrj/%
	$(IPS) $@ $^
$(IPSDIR)/landmakr/%.ips: $(OUTDIR)/landmakr/% $(ROMDIR)/landmakr/%
	$(IPS) $@ $^

$(ROMDIR)/%/: $(ROMDIR)/%.zip
	unzip $< -d $@

%_program.bin: $(ROMDIR)/%/
	$(INTERLEAVE) -i $(addprefix $<,$($*_program_romfiles)) -o $@

%_patched.o: %_program.bin $(SRC)
	$(AS) $(SRC) -D $* $(ASFLAGS) -o $@

%_patched.bin: %_patched.o
	$(P2BIN) $< $@ -r 0x0-0x1FFFFF

$(OUTDIR)/%/: $(ROMDIR)/%
	mkdir -p $@
	cp -uprt $@ $</*

clean:
	@-rm -r $(OUTDIR)
	@-rm *.o
	@-rm *.bin

