#!/bin/sh
# 2008-06-01

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	CC=${FR_CROSS_CC} \
	  ./configure --prefix=${FR_LIBCDIR} \
		  --host=`uname -m`-linux --build=${TARGET_CPU}-uclibc-linux \
		  || exit 1
#		  --host=`uname -m` --build=${FR_TARGET_DEFN} \

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
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
