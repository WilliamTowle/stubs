#!/bin/sh
# 2008-09-06

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

#TODO:- libtool complains at '--mode=link'

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=${FR_LIBCDIR} \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-shared \
		  || exit 1

# BUILD...
	case ${PKGVER} in
	4.5)
		make CC=${FR_HOST_CC} CFLAGS='' dftables || exit 1
	;;
	7.[348])
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	make DESTDIR='' install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
