#!/bin/sh
# grep v2.5.1a			STUBS (c) and GPLv2 Wm.Towle 1999-2010
# last mod WmT, 2010-12-29	[ since v?.?, c. ????-??-?? ]

. ./package.cfg || exit 1
#. ${TOPLEV}/Config/ENV/ifbuild.env || exit 1

do_build_nti()
{
# CONFIGURE...
	cd source/grep-${PKGVER} || exit 1

	CC=/usr/bin/gcc \
		./configure \
		  --prefix=${TCTREE}/usr \
		  --disable-largefile --disable-nls \
		  --without-included-regex \
		  || exit 1

## BUILD...
	make || exit 1

## INSTALL...
	make install || exit 1
}

##
##      main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
NTI)	## install to native userland
	do_build_nti $* || exit 1
;;
*)
        echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
        exit 1
;;
esac
