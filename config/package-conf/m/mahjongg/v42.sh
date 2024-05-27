#!/bin/sh
# mahjongg v42
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
	mkdir -p ${INSTTEMP}/mahjng42 || exit 1
	cp MAHJONGG.EXE   ${INSTTEMP}/mahjng42/mahjongg.exe
	cp MAHJONGG.DOC   ${INSTTEMP}/mahjng42/mahjongg.doc
	cp MAHJONGG.HLP   ${INSTTEMP}/mahjng42/mahjongg.hlp
	cp SHAREWRE.TXT   ${INSTTEMP}/mahjng42/sharewre.txt
	cp ORDERFRM.TXT   ${INSTTEMP}/mahjng42/orderfrm.txt
	cp UKORDER.TXT    ${INSTTEMP}/mahjng42/ukorder.txt
	cp VENDOR.TXT     ${INSTTEMP}/mahjng42/vendor.txt
	cp STATGEN.EXE    ${INSTTEMP}/mahjng42/statgen.exe
	cp MAHJONGG.TXT   ${INSTTEMP}/mahjng42/mahjongg.txt
	cp TILEARCH.BAT   ${INSTTEMP}/mahjng42/tilearch.bat
	cp FLAGS.TIL      ${INSTTEMP}/mahjng42/flags.til
	cp TEXTVIEW.EXE   ${INSTTEMP}/mahjng42/textview.exe
	cp ANTIGRAV.BRD   ${INSTTEMP}/mahjng42/antigrav.brd
	cp DEFAULT.BRD    ${INSTTEMP}/mahjng42/default.brd
	cp FLAGS.TXT      ${INSTTEMP}/mahjng42/flags.txt
	cp HORSESHU.BRD   ${INSTTEMP}/mahjng42/horseshu.brd
	cp STADIUM.BRD    ${INSTTEMP}/mahjng42/stadium.brd
	cp TOWERS.BRD     ${INSTTEMP}/mahjng42/towers.brd
	cp XRAY.BRD       ${INSTTEMP}/mahjng42/xray.brd
	cp FILE_ID.DIZ    ${INSTTEMP}/mahjng42/file_id.diz
	cp MAHJONGG.TIL   ${INSTTEMP}/mahjng42/mahjongg.til
	cp TILEMAKR.EXE   ${INSTTEMP}/mahjng42/tilemakr.exe
	cp TILEMAKR.DOC   ${INSTTEMP}/mahjng42/tilemakr.doc
	cp TILEMAKR.HLP   ${INSTTEMP}/mahjng42/tilemakr.hlp
	cp CATALOG.EXE    ${INSTTEMP}/mahjng42/catalog.exe
	cp TILES.DOC      ${INSTTEMP}/mahjng42/tiles.doc
	cp MAHJONGG.DAT   ${INSTTEMP}/mahjng42/mahjongg.dat
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
