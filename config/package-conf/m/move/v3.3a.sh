#!/bin/sh
# move v3.3
# Last modified WmT 2011-10-14
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos || exit 1
#	cp APPINFO/MOVE.LSM
#	cp NLS/MOVE.EN
#	cp NLS/MOVE.ES
	cp BIN/MOVE.EXE ${INSTTEMP}/dos/ || exit 1
#	cp BIN/_MOVE.EXE
#	cp DOC/MOVE
#	cp DOC/MOVE/COPYING.TXT
#	cp DOC/MOVE/README
#	cp DOC/MOVE/BUGS.TXT
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
