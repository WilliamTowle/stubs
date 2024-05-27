#!/bin/sh
# wmfd-init v2p
# Last modified WmT 2011-07-01
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/franki || exit 1

	cp autoexec.bat		${INSTTEMP}/ || exit 1
	cp config.sys		${INSTTEMP}/ || exit 1

	cp franki/lincopy.bat	${INSTTEMP}/franki/ || exit 1
	cp franki/doscopy.bat	${INSTTEMP}/franki/ || exit 1
	cp franki/utcopy.bat	${INSTTEMP}/franki/ || exit 1
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
