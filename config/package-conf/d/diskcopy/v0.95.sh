#!/bin/sh
# diskcopy v1.3.1
# Last modified WmT 2011-07-20
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos || exit 1
	cp BIN/DISKCOPY.EXE ${INSTTEMP}/dos/utils/diskcopy.exe || exit 1
	cp SOURCE/DISKCOPY/DISKCOPY.INI ${INSTTEMP}/dos/utils/diskcopy.ini || exit 1
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
