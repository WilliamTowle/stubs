#!/bin/sh
# tarot2 vUNKNOWN
# Last modified WmT 2011-07-22
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...
	#unzip unz600x3.exe || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/tarot2 || exit 1
	cp CARD_16.EXE  ${INSTTEMP}/tarot2/card_16.exe
	cp CARD_EGA.EXE ${INSTTEMP}/tarot2/card_ega.exe
	cp CARD_256.EXE ${INSTTEMP}/tarot2/card_256.exe
	cp README.1ST   ${INSTTEMP}/tarot2/readme.1st
	cp INSTALL.BAT  ${INSTTEMP}/tarot2/install.bat
	cp TAROT2.DOC   ${INSTTEMP}/tarot2/tarot2.doc
	cp T2.EXE       ${INSTTEMP}/tarot2/t2.exe
}

##
##	main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
CUI)	## install to cross-userland
	do_build_cui $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
	exit 1
;;
esac
