#!/bin/sh
# loadlin-cfg v0.4.5
# Last modified WmT 2011-03-14
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/franki/loadlin || exit 1

	cp loadlin/freg2040.cfg ${INSTTEMP}/franki/loadlin/ || exit 1
	cp loadlin/2040hda1.bat ${INSTTEMP}/franki/loadlin/ || exit 1
	cp loadlin/kpeg2040.cfg ${INSTTEMP}/franki/loadlin/ || exit 1
	cp loadlin/bxeg2039.cfg ${INSTTEMP}/franki/loadlin/ || exit 1
	cp loadlin/2040045.bat ${INSTTEMP}/franki/loadlin/ || exit 1
	cp loadlin/slak2037.cfg ${INSTTEMP}/franki/loadlin/ || exit 1
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
