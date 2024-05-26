#!/bin/sh
# nui-binutils v2.9.1		STUBS (c) and GPLv2 Wm.Towle 1999-2010
# last mod WmT, 2010-12-26	[ since v2.9.1, c.????-??-?? ]

#. ${TOPLEV}/Config/ENV/ifbuild.env || exit 1

do_build_nui()
{
	#echo ${SCRIPTBIN}/swinst.sh / ${PKG_SRC}
	( cd source/ && tar cvf - usr ) | ( cd / && tar xvf - )
	# binutils doinst.sh can be run verbatim
	( cd / && sh ${BUILDTEMP}/source/install/doinst.sh )
}

##
##      main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
NUI)	## install to native userland
	do_build_nui $* || exit 1
;;
*)
        echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
        exit 1
;;
esac
