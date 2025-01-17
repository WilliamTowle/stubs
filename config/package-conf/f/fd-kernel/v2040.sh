#!/bin/sh
# fd-kernel 2040	STUBS (c) and GPLv2 William Towle 1999-2009
# last modified		2011-07-01

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
