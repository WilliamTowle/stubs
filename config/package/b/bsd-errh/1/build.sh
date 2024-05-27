#!/bin/sh
# 09/07/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

#	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.7.x and later
##		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

#	CC=${FR_CROSS_CC} \
#	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls \
#		  || exit 1

# BUILD...

	( cd err_h || exit 1
		${FR_CROSS_CC} -c err.c -o err.o
	) || exit 1

# INSTALL...
	FR_CROSS_AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'`
	DIR_KRAGENSERRH=${FR_LIBCDIR}/err_h

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
