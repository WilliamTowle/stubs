#!/bin/sh
# 2008-06-01

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	1.0.2)
		CC=${FR_CROSS_CC} \
			./configure --prefix=${FR_LIBCDIR} \
			  --host=`uname -m`-misc-linux-gnu --build=${TARGET_CPU}-uclibc-linux \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

 BUILD...
	case ${PKGVER} in
	1.0.2)
		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	1.0.2)
		make install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-cross)
	make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac