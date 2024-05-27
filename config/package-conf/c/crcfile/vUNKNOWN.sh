#!/bin/sh
# crcfile vUNKNOWN
# Last modified WmT 2013-06-05
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2013

#	. package.cfg


do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/utils || exit 1

#	cp crc/CRCFILE.EXE ${INSTTEMP}/dos/utils/crcfile.exe || exit 1
	cp CRCfile.exe ${INSTTEMP}/dos/utils/crcfile.exe || exit 1
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
