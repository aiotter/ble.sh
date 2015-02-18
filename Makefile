# -*- mode:makefile-gmake -*-

all:
.PHONY: all dist

outfiles+=out
out:
	mkdir -p $@

outfiles+=out/ble.sh
out/ble.sh: ble.pp ble-core.sh ble-decode.sh ble-getopt.sh ble-edit.sh ble-color.sh ble-syntax.sh
	mwg_pp.awk $< >/dev/null

outfiles+=out/cmap
out/cmap:
	mkdir -p $@

outfiles+=out/cmap/default.sh
out/cmap/default.sh: cmap/default.sh
	cp -p $< $@

all: $(outfiles)

dist:
	cd .. && tar cavf "$$(date +ble.%Y%m%d.tar.xz)" ./ble --exclude=./ble/backup --exclude=*~ --exclude=./ble/.git

listf:
	awk '/^[[:space:]]*function/{sub(/^[[:space:]]*function[[:space:]]*/,"");sub(/[[:space:]]*\{[[:space:]]*$$/,"");print $$0}' ble.sh |sort
