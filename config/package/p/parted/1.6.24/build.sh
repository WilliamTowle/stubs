#!/bin/sh
# 22/10/2005

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

	PATH=${TCTREE}/${FR_LIBCDIR}/bin:${PATH} \
	  ac_cv_header_wchar_h=no \
	  ac_cv_sys_file_offset_bits=32 \
	  CC=${FR_CROSS_CC} \
	  CFLAGS="-O2" \
		./configure --prefix=/usr \
		  --host=`uname -m`-`uname -s | tr 'A-Z' 'a-z'` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --without-readline \
		  || exit 1

	case ${PKGVER} in
	1.6.24)
# | sed '/^INCLUDES/ s%=%= -nostdinc -I'${TCTREE}/${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
		# There are build errors(??!!) ...adjust Makefile[s]
		find ./ -name *[Mm]akefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/ *-Wno-unused */ /' \
				| sed '/^CFLAGS/ s/ *-Werror */ /' \
				> ${MF} || exit 1
		done

		# no means of unrequiring wchar.h ...fudge.
		[ -r parted/strlist.h.OLD ] \
			|| mv parted/strlist.h parted/strlist.h.OLD || exit 1
		cat parted/strlist.h.OLD \
			| sed 's/#include <wchar.h>/#define wchar_t char/' \
			> parted/strlist.h || exit 1
		;;
	esac

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
