landmakrj_program_romfiles = e61-13.20 e61-12.19 e61-11.18 e61-10.17
landmakr_program_romfiles = e61-19.20 e61-18.19 e61-17.18 e61-16.17
ROMDIR = ../roms
SRC = patch.S
TARGETS = landmakr landmakrj

OUTDIR = out
AS = asl
P2BIN = p2bin
ZIP = zip
IPS = uips c
INTERLEAVE = ../util/interleave.rb
DEINTERLEAVE = ../util/deinterleave.rb
ASFLAGS=-i . -i .. -n -U -q

.PHONY: landmakr landmakrj ips landmakr_ips landmakrj_ips
.PRECIOUS: %_program.bin

all: $(TARGETS)
landmakr: $(OUTDIR)/landmakr/
landmakrj: $(OUTDIR)/landmakrj/

$(ROMDIR)/%/: $(ROMDIR)/%.zip
	unzip $< -d $@

%_program.bin: $(ROMDIR)/%/
	$(INTERLEAVE) -i $(addprefix $<,$($*_program_romfiles)) -o $@

%_patched.o: %_program.bin $(SRC)
	@echo $*
	$(AS) $(SRC) -D $* $(ASFLAGS) -o $@

%_patched.bin: %_patched.o
	$(P2BIN) $< $@ -r 0x0-0x1FFFFF

$(OUTDIR)/%/: $(ROMDIR)/% %_patched.bin
	mkdir -p $@
	cp -urt $@ $</*
	$(DEINTERLEAVE) -i $*_patched.bin -o $($*_program_romfiles)
	mv $($*_program_romfiles) $@


$(OUTDIR)/landmakrj/%.ips: $(OUTDIR)/landmakrj/% $(ROMDIR)/landmakrj/%
	$(IPS) $@ $^
$(OUTDIR)/landmakr/%.ips: $(OUTDIR)/landmakr/% $(ROMDIR)/landmakr/%
	$(IPS) $@ $^
ips: landmakr_ips landmakrj_ips
landmakr_ips: landmakr $(addsuffix .ips,$(addprefix $(OUTDIR)/landmakr/,$(landmakr_program_romfiles)))
landmakrj_ips: landmakrj $(addsuffix .ips,$(addprefix $(OUTDIR)/landmakrj/,$(landmakrj_program_romfiles)))

clean:
	@-rm -r $(OUTDIR)
	@-rm *.o
	@-rm *.bin

