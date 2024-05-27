#!/bin/sh
# fd-kernel 2035_32, last modified WmT 2011-01-07
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	cp BIN/KERNEL.SYS ${INSTTEMP}/kernel.sys
	cp BIN/CONFIG.SYS ${INSTTEMP}/config16.sys
	cp BIN/AUTOEXEC.BAT ${INSTTEMP}/autoexec.b16
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
