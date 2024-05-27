#!/bin/sh
# sw39-tools v0.9		[ since v0.1, c.2009-12-15 ]
# last mod WmT, 2010-08-12	[ (c) and GPLv2 1999-2010 ]

#. ${TOPLEV}/Config/ENV/ifbuild.env || exit 1

do_nti()
{
	echo "...TODO: copy scripts to toolchain" 1>&2
	exit 1
}


##
##      main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
NTI)	do_nti || exit 1
;;
*)
        echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
        exit 1
;;
esac || exit 1
