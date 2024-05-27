#!/bin/sh
# 2008-06-22

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_tc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

# BUILD...

	( cd err_h || exit 1
		${FR_CROSS_CC} -c err.c -o err.o
	) || exit 1

# INSTALL...
	FR_CROSS_AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'`
	DIR_KRAGENSERRH=${FR_LIBCDIR}/include/err_h

	mkdir -p ${DIR_KRAGENSERRH} || exit 1
	cp err_h/err.h ${DIR_KRAGENSERRH} || exit 1
	${FR_CROSS_AR} ruv ${FR_LIBCDIR}/lib/liberr.a err_h/err.o
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
