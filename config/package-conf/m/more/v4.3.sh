#!/bin/sh
# more v4.3
# Last modified WmT 2011-03-04
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos || exit 1
	cp bin/MORE.EXE ${INSTTEMP}/dos/more.exe || exit 1
#INSTALL MORE40/BIN/_MORE.EXE      MORE40/BIN/_MORE.EXE
#INSTALL MORE40/NLS/               MORE40/NLS/
#INSTALL MORE40/NLS/MORE.DE        MORE40/NLS/MORE.DE
#INSTALL MORE40/NLS/MORE.LV        MORE40/NLS/MORE.LV
#INSTALL MORE40/NLS/MORE.SV        MORE40/NLS/MORE.SV
#INSTALL MORE40/NLS/MORE.NL        MORE40/NLS/MORE.NL
#INSTALL MORE40/NLS/MORE.HU        MORE40/NLS/MORE.HU
#INSTALL MORE40/NLS/MORE.EN        MORE40/NLS/MORE.EN
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
