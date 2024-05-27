#!/bin/sh
# 04/06/2003

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_build()
{
# CONFIGURE...
	[ -r DEFAULTS/Defaults.linux.OLD ] || cp DEFAULTS/Defaults.linux DEFAULTS/Defaults.linux.OLD
	cat DEFAULTS/Defaults.linux.OLD \
		| sed "s%^DEFCCOM%#DEFCCOM%" \
		| sed "s%^#DEFCCOM.*gcc%DEFCCOM=	${TARGET_CPU}-uclibc-gcc%" \
		| sed "s%^INS_BASE=.*%INS_BASE=${INSTTEMP}/usr%" \
		| sed "s%^INS_KBASE=.*%INS_KBASE=/usr%" \
		> DEFAULTS/Defaults.linux
	( cd RULES && ln -sf ${TARGET_CPU}-linux-gcc.rul `uname -m`-linux-${TARGET_CPU}-uclibc-gcc.rul ) || exit 1

# BUILD...
	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH} \
		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_tc_host()
{
	[ -r DEFAULTS/Defaults.linux.OLD ] || cp DEFAULTS/Defaults.linux DEFAULTS/Defaults.linux.OLD
	cat DEFAULTS/Defaults.linux.OLD \
		| sed "s%^INS_BASE=.*%INS_BASE=${INSTTEMP}/usr%" \
		> DEFAULTS/Defaults.linux

	make || exit 1
	make install || exit 1
}

case "$1" in
distro-cross)
	make_build || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_tc_host || exit 1
	;;
*)
	exit 1
	;;
esac
