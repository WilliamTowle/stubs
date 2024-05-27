#!/bin/sh
# fdisk 1.3.1		STUBS (c) and GPLv2 Wm. Towle 1999-2011
# last modified		2011-01-06

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos || exit 1
	cp PROGRAM/FDISK.EXE ${INSTTEMP}/dos/fdisk.exe || exit 1
	cp PROGRAM/FDISK.INI ${INSTTEMP}/dos/fdisk.ini || exit 1
	cp PROGRAM/FDISKPT.INI ${INSTTEMP}/dos/fdiskpt.ini || exit 1
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
