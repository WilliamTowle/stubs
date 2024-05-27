#!/bin/sh
# freecom v0.83b26
# last modified WmT 2011-01-06
# STUBS scripts and configurations (c) and GPLv2 William Towle 1999-2009

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source

# BUILD...

# INSTALL...
	#cp command.com ${BUILDROOT}/dos/utils/
	cp command.com ${INSTTEMP}/ || exit 1
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
