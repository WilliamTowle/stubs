#!/bin/sh
# 15/09/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	case ${PKGVER} in
	0.9.*)
		# requires assertion features.conf exists for cross compilation
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  ac_cv_file___features_conf=yes \
		  ac_cv_func_setvbuf_reversed=no \
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --without-x \
			  `uname -s | tr A-Z a-z` \
			  || exit 1
		;;
	0.10.5|0.10.6)
		[ -r configure.OLD ] || mv configure configure.OLD || exit 1
		cat configure.OLD \
			| sed 's%^builddir=.*%builddir=.%' \
			| sed 's%^srcdir=.*%srcdir=.%' \
			> configure || exit 1
		chmod a+x configure || exit 1

		# requires assertion features.conf exists for cross compilation
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  ac_cv_file___features_conf=yes \
		  ac_cv_func_setvbuf_reversed=no \
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --without-x \
			  `uname -s | tr A-Z a-z` \
			  || exit 1

		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed 's%^AR *= *ar%AR='`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'`'%' \
				> ${MF} || exit 1
		done

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
