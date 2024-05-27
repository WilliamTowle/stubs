#!/bin/sh
# xkeyb v1.15
# Last modified WmT 2011-03-04
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/key || exit 1

#	cp BIN/KEYB.BAT ${INSTTEMP}/dos/keyb.bat || exit 1
	cp BIN/KEYMAN.EXE ${INSTTEMP}/dos/keyman.exe || exit 1
	cp BIN/LISTXDEF.EXE ${INSTTEMP}/dos/listxdef.exe || exit 1
#	cp BIN/SCANKBD.EXE ${INSTTEMP}/dos/scankbd.exe || exit 1
	cp BIN/XKEYB.EXE ${INSTTEMP}/dos/xkeyb.exe || exit 1
	cp BIN/XKEYBRES.EXE ${INSTTEMP}/dos/xkeybres.exe || exit 1

#	cp BIN/PC437.KEY ${INSTTEMP}/dos/key/pc437.key || exit 1
#	cp BIN/KEY/BE.KEY ${INSTTEMP}/dos/key/be.key || exit 1
#	cp BIN/KEY/BE-CP437.KEY ${INSTTEMP}/dos/key/be-cp437.key || exit 1
#	cp BIN/KEY/BR274.KEY ${INSTTEMP}/dos/key/br274.key || exit 1
#	cp BIN/KEY/BR274437.KEY ${INSTTEMP}/dos/key/br274437.key || exit 1
#	cp BIN/KEY/CF.KEY ${INSTTEMP}/dos/key/cf.key || exit 1
#	cp BIN/KEY/CF-CP863.KEY ${INSTTEMP}/dos/key/cf-cp863.key || exit 1
#	cp BIN/KEY/CZ.KEY ${INSTTEMP}/dos/key/cz.key || exit 1
#	cp BIN/KEY/DK.KEY ${INSTTEMP}/dos/key/dk.key || exit 1
#	cp BIN/KEY/DK-CP865.KEY ${INSTTEMP}/dos/key/dk-cp437.key || exit 1
#	cp BIN/KEY/FR.KEY ${INSTTEMP}/dos/key/fr.key || exit 1
#	cp BIN/KEY/FR-CP437.KEY ${INSTTEMP}/dos/key/fr-cp437.key || exit 1
#	cp BIN/KEY/GR.KEY ${INSTTEMP}/dos/key/gr.key || exit 1
#	cp BIN/KEY/GR-CP437.KEY ${INSTTEMP}/dos/key/gr-cp437.key || exit 1
#	cp BIN/KEY/HU.KEY ${INSTTEMP}/dos/key/hu.key || exit 1
#	cp BIN/KEY/HU208.KEY ${INSTTEMP}/dos/key/hu208.key || exit 1
#	cp BIN/KEY/IT.KEY ${INSTTEMP}/dos/key/it.key || exit 1
#	cp BIN/KEY/IT-CP437.KEY ${INSTTEMP}/dos/key/it-cp437.key || exit 1
#	cp BIN/KEY/IT142.KEY ${INSTTEMP}/dos/key/it142.key || exit 1
#	cp BIN/KEY/IT142437.KEY ${INSTTEMP}/dos/key/it142437.key || exit 1
#	cp BIN/KEY/LA.KEY ${INSTTEMP}/dos/key/la.key || exit 1
#	cp BIN/KEY/LA-CP437.KEY ${INSTTEMP}/dos/key/la-cp437.key || exit 1
#	cp BIN/KEY/NL.KEY ${INSTTEMP}/dos/key/nl.key || exit 1
#	cp BIN/KEY/NL-CP437.KEY ${INSTTEMP}/dos/key/nl-cp437.key || exit 1
#	cp BIN/KEY/NO.KEY ${INSTTEMP}/dos/key/no.key || exit 1
#	cp BIN/KEY/NO-CP865.KEY ${INSTTEMP}/dos/key/no-cp865.key     || exit 1
#	cp BIN/KEY/PL.KEY ${INSTTEMP}/dos/key/pl.key || exit 1
#	cp BIN/KEY/PO.KEY ${INSTTEMP}/dos/key/po.key || exit 1
#	cp BIN/KEY/PO-CP860.KEY ${INSTTEMP}/dos/key/po-cp860.key || exit 1
#	cp BIN/KEY/SF.KEY ${INSTTEMP}/dos/key/sf.key || exit 1
#	cp BIN/KEY/SF-CP437.KEY ${INSTTEMP}/dos/key/sf-cp437.key || exit 1
#	cp BIN/KEY/SG.KEY ${INSTTEMP}/dos/key/sg.key || exit 1
#	cp BIN/KEY/SG-CP437.KEY ${INSTTEMP}/dos/key/sg-cp437.key || exit 1
#	cp BIN/KEY/SK.KEY ${INSTTEMP}/dos/key/sk.key || exit 1
#	cp BIN/KEY/SP.KEY ${INSTTEMP}/dos/key/sp.key || exit 1
#	cp BIN/KEY/SP-CP437.KEY ${INSTTEMP}/dos/key/sp-cp437.key || exit 1
#	cp BIN/KEY/SU.KEY ${INSTTEMP}/dos/key/su.key || exit 1
#	cp BIN/KEY/SU-CP437.KEY ${INSTTEMP}/dos/key/su-cp437.key || exit 1
#	cp BIN/KEY/SV.KEY ${INSTTEMP}/dos/key/sv.key || exit 1
#	cp BIN/KEY/SV-CP437.KEY ${INSTTEMP}/dos/key/sv-cp437.key || exit 1
	cp BIN/KEY/UK.KEY ${INSTTEMP}/dos/key/uk.key || exit 1
#	cp BIN/KEY/UK-CP437.KEY ${INSTTEMP}/dos/key/uk-cp437.key || exit 1
#	cp BIN/KEY/UK168.KEY ${INSTTEMP}/dos/key/uk168.key || exit 1
#	cp BIN/KEY/UK168437.KEY ${INSTTEMP}/dos/key/uk168437.key     || exit 1
	cp BIN/KEY/US.KEY ${INSTTEMP}/dos/key/us.key || exit 1
#	cp BIN/KEY/YU.KEY ${INSTTEMP}/dos/key/yu.key || exit 1
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
