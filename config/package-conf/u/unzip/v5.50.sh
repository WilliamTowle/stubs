#!/bin/sh
# unzip v5.50
# Last modified WmT 2011-03-14
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...
	unzip unz550x.exe || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/utils || exit 1
	cp unzip.exe ${INSTTEMP}/dos/utils/ || exit 1
	cp funzip.exe ${INSTTEMP}/dos/utils/ || exit 1
	cp unzipsfx.exe ${INSTTEMP}/dos/utils/ || exit 1
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
