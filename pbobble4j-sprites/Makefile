pbobble4j_program_romfiles = e49-12.20 e49-11.19 e49-10.18 e49-09.17

ROMDIR = ../roms
OUTDIR = out
IPSDIR = ips
SRC = patch.S
AS = asl
ASFLAGS=-i . -i .. -n -U -q -l +t 70 -r 1
P2BIN = p2bin
ZIP = zip
IPS = uips c
INTERLEAVE = ruby ../util/interleave.rb
DEINTERLEAVE = ruby ../util/deinterleave.rb
TARGETS = pbobble4j

.PHONY: pbobble4j ips pbobble4j_ips
.PRECIOUS: %_program.bin

all: $(TARGETS)

PBOBBLE4J_OUT_ROMFILES = $(addprefix $(OUTDIR)/pbobble4j/,$(pbobble4j_program_romfiles))
PBOBBLE4J_OUT_IPSFILES = $(addsuffix .ips,$(addprefix $(IPSDIR)/pbobble4j/,$(pbobble4j_program_romfiles)))
pbobble4j: $(PBOBBLE4J_OUT_ROMFILES)
ips: pbobble4j_ips

pbobble4j_ips: pbobble4j $(IPSDIR)/pbobble4j $(PBOBBLE4J_OUT_IPSFILES)

$(PBOBBLE4J_OUT_ROMFILES): $(OUTDIR)/pbobble4j pbobble4j_patched.bin
	$(DEINTERLEAVE) -i pbobble4j_patched.bin -o $(PBOBBLE4J_OUT_ROMFILES)

$(IPSDIR)/%:
	mkdir -p $@
$(IPSDIR)/pbobble4j/%.ips: $(ROMDIR)/pbobble4j/% $(OUTDIR)/pbobble4j/%
	$(IPS) $@ $^

$(ROMDIR)/%: $(ROMDIR)/%.zip
	unzip $< -d $@
	unzip ../roms/pbobble4.zip -d $@

%_program.bin: $(ROMDIR)/%/
	$(INTERLEAVE) -i $(addprefix $<,$($*_program_romfiles)) -o $@

%_patched.o: %_program.bin $(SRC)
	$(AS) $(SRC) -D $* $(ASFLAGS) -o $@

%_patched.bin: %_patched.o
	$(P2BIN) $< $@ -r 0x0-0x1FFFFF

$(OUTDIR)/%: $(ROMDIR)/%
	mkdir -p $@
	cp -uprt $@ $</*

clean:
	@-rm -r $(OUTDIR)
	@-rm *.o
	@-rm *.bin

