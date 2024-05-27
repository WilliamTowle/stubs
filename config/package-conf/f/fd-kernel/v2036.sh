#!/bin/sh
# fd-kernel 2036, last modified WmT 2011-01-06
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

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
