#!/bin/sh
# nui-lx20 v2.0.40		STUBS (c) and GPLv2 Wm.Towle 1999-2010
# last mod WmT, 2010-12-29	[ since v2.0.40, c.2004-04-18 ]

. ./package.cfg || exit 1
#. ${TOPLEV}/Config/ENV/ifbuild.env || exit 1

do_build_nui()
{
# CONFIGURE...
	if [ "`find source -type f | grep '^-type$'`" ] ; then
		echo "$0: Aborting: unsophisticated 'find' breaks prerequisites" 1>&2
		exit 1
	fi

	cd source/linux-${PKGVER} || exit 1

# BUILD...
# 2010-12-28: bodgeness
if [ ! -r Makefile ] ; then
	echo "$0: confused: pre-mrproper and no Makefile" 1>&2
	exit 1
fi
#
	make mrproper || exit 1
if [ ! -r Makefile ] ; then
	echo "$0: confused: post-mrproper and no Makefile" 1>&2
	exit 1
fi
	if [ "CPU${TARGET_CPU}" = 'CPU' ] ; then
		echo "$0: NO TARGET_CPU set" 1>&2
		exit 1
	fi

	( cd include && rm ./asm 2>/dev/null )
# 2010-12-28: No 'symlinks' target for 2.0.40??!
echo "-----"
pwd
ls
echo "-----"
#	make symlinks || exit 1
if [ -r Makefile ] ; then
	echo "$0: Fixed??" 1>&2
	exit 1
fi
	make include/linux/version.h || exit 1
	touch include/linux/autoconf.h || exit 1
	cp arch/${TARGET_CPU}/defconfig .config || exit 1
	make bzImage |

# INSTALL...
	echo "INSTALL INCOMPLETE" ; exit 1
#	mkdir -p ${INSTTEMP}/usr/src || exit 1
#	( cd ${INSTTEMP}/usr/src/ &&
#		[ -d linux-${PKGVER} ] || mkdir linux-${PKGVER}
#		[ -L linux ] && rm ./linux
#		ln -s linux-${PKGVER} linux
#	) || exit 1
#	tar cvf - * .[a-z]* \
#		| ( cd ${INSTTEMP}/usr/src/linux-${PKGVER} && tar xvf - )
	mkdir -p ${INSTTEMP}/usr/include || exit 1
	( cd include &&
		rm -rf *-${PKGVER}
		tar cvf - linux/* asm/* \
			| ( cd ${INSTTEMP}/usr/include && tar xvf - )
	) || exit 1
	( cd ${INSTTEMP}/usr/include &&
		mv linux linux-${PKGVER} &&
		ln -s linux-${PKGVER} linux &&
		mv asm asm-${PKGVER} &&
		ln -s asm-${PKGVER} asm
	) || exit 1
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
