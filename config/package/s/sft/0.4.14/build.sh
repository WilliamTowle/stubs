#!/bin/sh
# 24/09/2005

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
	fi
# GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1
#
#		for MF in `find ./ -name Makefile` ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/^CFLAGS/ s/-g //' \
#				| sed '/^prefix/ s%/usr%${DESTDIR}/usr%' \
#				> ${MF} || exit 1
#		done
#		;;
#	0.8.7)
#		# no more ./configure since 0.8.7
#		for MF in `find ./ -name Makefile` ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/^CC *=/ s%gcc%'${FR_CROSS_CC}'%' \
#				| sed '/^prefix/ s%/usr%${DESTDIR}/usr%' \
#				> ${MF} || exit 1
#		done
#		;;
#	*)
#		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#		;;
#	esac

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
