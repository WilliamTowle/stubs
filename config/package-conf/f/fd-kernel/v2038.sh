#!/bin/sh
# fd-kernel 2038	STUBS (c) and GPLv2 William Towle 1999-2012
# last modified		2012-03-26

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	#cp bin/kernel.sys ${BUILDROOT}/dos/utils/
	cp bin/kernel.sys ${INSTTEMP}/ || exit 1
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
