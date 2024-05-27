#!/bin/sh
# setver v6.1
# last modified WmT 2011-01-06
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/utils/ || exit 1
	cp Setver.exe ${INSTTEMP}/dos/utils/setver.exe || exit 1
#INSTALL Setver.asm	Setver.asm
#INSTALL Readme.txt	Readme.txt
#INSTALL Packing.lst	Packing.lst
#INSTALL License	License
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
