#!/bin/sh
# fd-sys 2041		STUBS (c) and GPLv2 Wm. Towle 1999-2011
# last modified		2012-03-2

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos || exit 1
	cp bin/sys.com ${INSTTEMP}/dos || exit 1
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
