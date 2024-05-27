#!/bin/sh
# linld v097
# Last modified WmT 2011-08-08
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2013

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/franki/linld || exit 1
	cp LINLD.COM ${INSTTEMP}/franki/linld/ || exit 1
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
