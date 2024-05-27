#!/bin/sh
# 2008-05-26 (prev 2007-03-04)

#TODO:- kingpin/SuSE build needs libz.h for static build

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
		echo "$0: Failed: No zlib.h?" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	4.1[23]) ;;
	*)
		if [ ! -r ${FR_TH_ROOT}/usr/bin/file ] ; then
			echo "$0: Failed: No 'file' in toolchain" 1>&2
			exit 1
		fi
	;;
	esac

	  CC=${FR_CROSS_CC} \
	    CFLAGS="-O2" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile || exit 1

# BUILD...
	case ${PKGVER} in
	4.12)
		# build natively to make 'magic' file:
		make CC=${FR_HOST_CC} CCDEPMODE='depmode=gcc' \
			-C src file || exit 1
		make CC=${FR_HOST_CC} CCDEPMODE='depmode=gcc' \
			-C magic all || exit 1

		make -C src clean || exit 1
		make CCDEPMODE='depmode=gcc' || exit 1
	;;
	4.13)
		# build natively to make 'magic' file:
		make CC=${FR_HOST_CC} CCDEPMODE='depmode=gcc' -C src file || exit 1
		make CC=${FR_HOST_CC} CCDEPMODE='depmode=gcc' -C magic all || exit 1

		make -C src clean || exit 1
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make CCDEPMODE='depmode=gcc' || exit 1
	;;
	4.18|4.24)
		[ -r magic/Makefile.OLD ] || mv magic/Makefile magic/Makefile.OLD || exit 1
		cat magic/Makefile.OLD \
			| sed '/^FILE_COMPILE *=/	s%file%'${FR_TH_ROOT}'/usr/bin/file%' \
			> magic/Makefile || exit 1

		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
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

#	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
#		echo "$0: Failed: No zlib.h?" 1>&2
#		exit 1
#	fi

	  CC=${FR_HOST_CC} \
	    CFLAGS="-O2" \
		./configure --prefix=${FR_TH_ROOT}/usr \
		  --disable-nls --disable-largefile \
		  --without-zlib \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
toolchain-host)
	make_th || exit 1
;;
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
