#!/bin/sh
# 04/01/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_build()
{
# CONFIGURE...
# BUILD...
# INSTALL...
	mkdir -p ${TCTREE}/etc/${USE_DISTRO} || exit 1

	mkdir -p ${INSTTEMP} || exit 1
	TCTREE=${TCTREE} USE_DISTRO=${USE_DISTRO} \
		make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_build || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_tc_host || exit 1
#	;;
*)
	exit 1
	;;
esac
