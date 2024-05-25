#!/bin/sh
# microtest-script v0.9.0	STUBS (c) and GPLv2 1999-2010
# last modified			2010-11-24

do_configure()
{
	pwd
	ls -la

#	. package.cfg

#	cd source
}

handle_nti()
{
# CONFIGURE...
	do_configure || exit 1

# BUILD...

# INSTALL...
}

##
##	main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
NTI)		## Build distro version
	handle_nti $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDMODE '${BUILDMODE}'" 1>&2
	exit 1
;;
esac
