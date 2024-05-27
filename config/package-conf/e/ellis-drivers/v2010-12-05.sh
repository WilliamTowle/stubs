#!/bin/sh
# ellis-drivers v2010-12-05
# Last modified WmT 2011-01-12
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/drivers || exit 1
#	# RAMDISK driver (also RDISKON.com)
#	cp RDISK.COM ${INSTTEMP}/dos/rdisk.com || exit 1
	cp UIDE.SYS ${INSTTEMP}/dos/drivers/uide.sys || exit 1
#	# Memory management driver
#	cp XMGR.SYS ${INSTTEMP}/dos/drivers/xmgr.sys || exit 1
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
