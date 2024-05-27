#!/bin/sh
# nui-gcc v2.7.2.3		[ since v2.7.2.3, c.????-??-?? ]
# last mod WmT, 2010-04-11	[ (c) and GPLv2 1999-2010 ]

. ${TOPLEV}/Config/ENV/ifbuild.env || exit 1

do_build_nui()
{
        ${SCRIPTBIN}/swinst.sh / ${PKG_SRC} || exit 1
}


##
##      main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
NUI)	## Build native package and install
	do_build_nui $* || exit 1
;;
*)
        echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
        exit 1
;;
esac
