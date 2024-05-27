#!/bin/sh
# edit v0.8.2
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
	cp EDIT.EXE ${INSTTEMP}/dos/edit.exe || exit 1
	cp EDIT.HLP ${INSTTEMP}/dos/edit.hlp || exit 1
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
