#!/bin/sh
# dos2unix v5.3.3
# Last modified WmT 2012-04-01
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2012

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/utils || exit 1
	cp bin/dos2unix.exe ${INSTTEMP}/dos/utils/ || exit 1
	cp bin/unix2dos.exe ${INSTTEMP}/dos/utils/ || exit 1
#	cp bin/mac2unix.exe ${INSTTEMP}/dos/utils/ || exit 1
#	cp bin/unix2mac.exe ${INSTTEMP}/dos/utils/ || exit 1
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
