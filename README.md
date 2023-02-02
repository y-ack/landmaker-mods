## getting started / prerequisites
you will need a linux environment (wsl, mingw...) with `ruby` and `make`

**you will also need [the macroassembler as](http://john.ccac.rwth-aachen.de:8000/as/) providing `asl`.**
get `mas` from the [AUR](https://aur.archlinux.org/packages/mas) or [download](http://john.ccac.rwth-aachen.de:8000/as/download.html) and build:
```sh
wget http://john.ccac.rwth-aachen.de:8000/ftp/as/source/c_version/asl-current-142-bld213.tar.bz2
tar -xf asl-current-142-bld213.tar.gz
cd asl-current
# copy appropriate makefile.def, e.g.:
cp Makefile.def-samples/Makefile.def-unknown-linux Makefile.def
make
make install
```

## usage / applying assembly patches
**NOTE:** make sure original roms `landmakr.zip` and `landmakrj.zip` are in the `roms/` folder.

run `make` in any patch subfolder  
patched files will be in `out/`

additional make targets:
 - `make ips` :: create ips patch files (requires cmdpack-uips)
 - `make landmakr` :: Land Maker 2.02O-only target
 - `make landmakrj` :: Land Maker 2.01J-only target

the steps for patching are:
1) interleave source files into program binary
2) assemble `patch.S` over original program  using `asl`
3) generate patched program binary from object file with `p2bin`
4) deinterleave patched binary into original rom files
5) package up new files, create ips patches

## development / how to make a patch (wip)
1) copy `example/` template with assembler source and makefile
2) write patch
3) `make landmakr` or `make landmakrj`


to make patches compatible with both rom versions, include the shift table:
[**shifts.S**](shifts.S)

for every ROM address referenced, add the closest SHIFT constant less than the desired address.
for example:
```s
	ORG $8EC70 + SHIFT_15FBC
	ORG $93BF4 + SHIFT_91470
	ORG $1FFFFE + SHIFT_A1416
```
for more information on the shift tables and their derivation, see: https://qcs.shsbs.xyz/share/ywy/land-maker#shifts

rom map: < wip >

## other
https://github.com/y-ack/landmaker-color-mod

y's land maker investigation home page: https://qcs.shsbs.xyz/share/ywy/land-maker
