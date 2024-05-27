#!/bin/sh
# 05/02/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
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

	case ${PKGVER} in
#	0.8.10)
#		PATH=${FR_LIBCDIR}/bin:${PATH} \
#		  ac_cv_func_malloc_0_nonnull=yes \
#		  ac_cv_func_realloc_0_nonnull=yes \
#		  CC=${FR_CROSS_CC} \
#			./configure --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --disable-largefile --disable-nls \
#			  CFLAGS='-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include -O2' \
#			  || exit 1
#		;;
#	0.8.12|0.8.13|0.9.0|0.9.1)
#		# need to persuade configure we have ntohs() since 0.8.12
#		PATH=${FR_LIBCDIR}/bin:${PATH} \
#		  ac_cv_func_malloc_0_nonnull=yes \
#		  ac_cv_func_realloc_0_nonnull=yes \
#		  ac_cv_func_ntohs=yes \
#		  CC=${FR_CROSS_CC} \
#			./configure --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --disable-largefile --disable-nls \
#			  || exit 1
#		;;
#	0.9.2|0.9.5)
#		# need to persuade configure we have ntohs() since 0.8.12
#		# md5.h needs UINT4 definition in 0.9.2
#		PATH=${FR_LIBCDIR}/bin:${PATH} \
#		  ac_cv_func_malloc_0_nonnull=yes \
#		  ac_cv_func_realloc_0_nonnull=yes \
#		  ac_cv_func_ntohs=yes \
#		  CC=${FR_CROSS_CC} \
#			./configure --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --disable-largefile --disable-nls \
#			  || exit 1
#
#		[ -r md5.h.OLD ] || mv md5.h md5.h.OLD || exit 1
#		( echo '#include "md5global.h"'
#			cat md5.h.OLD ) \
#			> md5.h || exit 1
#
#		[ -r md5global.h.OLD ] || mv md5global.h md5global.h.OLD || exit 1
#		( echo '#ifndef _MD5_GLOBAL_H'
#			echo '#define _MD5_GLOBAL_H'
#			cat md5global.h.OLD
#			echo '#endif') \
#			> md5global.h || exit 1
#		;;
	0.9.6-1)
		# need to persuade configure we have ntohs() since 0.8.12
		  ac_cv_func_malloc_0_nonnull=yes \
		  ac_cv_func_realloc_0_nonnull=yes \
		  ac_cv_func_ntohs=yes \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --disable-gnutls \
			  || exit 1

#		# md5.h needs UINT4 definition in 0.9.2
#		[ -r md5.h.OLD ] || mv md5.h md5.h.OLD || exit 1
#		( echo '#include "md5global.h"'
#			cat md5.h.OLD ) \
#			> md5.h || exit 1

#		[ -r md5global.h.OLD ] || mv md5global.h md5global.h.OLD || exit 1
#		( echo '#ifndef _MD5_GLOBAL_H'
#			echo '#define _MD5_GLOBAL_H'
#			cat md5global.h.OLD
#			echo '#endif') \
#			> md5global.h || exit 1
		;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
