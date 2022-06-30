landmakrj_program_romfiles = e61-13.20 e61-12.19 e61-11.18 e61-10.17
landmakr_program_romfiles = e61-19.20 e61-18.19 e61-17.18 e61-16.17
ROMDIR = ../roms
SRC = patch.S

OUTDIR = out
AS = asl
P2BIN = p2bin
INTERLEAVE = ../util/interleave.rb
DEINTERLEAVE = ../util/deinterleave.rb

ASFLAGS=-i . -n -U -q

all: $(OUTDIR)/landmakr/ $(OUTDIR)/landmakrj/

$(ROMDIR)/landmakrj/: $(ROMDIR)/landmakrj.zip
	unzip $< -d $@
$(ROMDIR)/landmakr/: $(ROMDIR)/landmakr.zip
	unzip $< -d $@

landmakrj_program.bin: $(ROMDIR)/landmakrj/
	$(INTERLEAVE) -i $(addprefix $<,$(landmakrj_program_romfiles)) -o $@

landmakr_program.bin: $(ROMDIR)/landmakr/
	$(INTERLEAVE) -i $(addprefix $<,$(landmakr_program_romfiles)) -o $@

%.o: %_program.bin
	$(AS) $(SRC) -D $* $(ASFLAGS) -o $@

%_patched.bin: %.o
	$(P2BIN) $< $@

$(landmakrj_program_romfiles): landmakrj_patched.bin
	$(DEINTERLEAVE) -i $< -o $@
$(landmakr_program_romfiles): landmakr_patched.bin
	$(DEINTERLEAVE) -i $< -o $@

$(OUTDIR)/landmakrj/: $(ROMDIR)/landmakrj/ $(landmakrj_program_romfiles)
	mkdir -p $@
	find $< -mindepth 1 -maxdepth 1 -type f -exec cp -t $@ {} +
	mv $(landmakrj_program_romfiles) $@

$(OUTDIR)/landmakr/: $(ROMDIR)/landmakr/ $(landmakr_program_romfiles)
	mkdir -p $@
	find $< -mindepth 1 -maxdepth 1 -type f -exec cp -t $@ {} +
	mv $(landmakr_program_romfiles) $@


clean:
	@-rm -r $(OUTDIR)
	@-rm *.o
	@-rm landmakrj_patched.bin landmakr_patched.bin
	@-rm landmakrj_program.bin landmakr_program.bin
