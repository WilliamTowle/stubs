#!/bin/sh
# 16/01/2005

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

	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
		ADD_LDFLAGS_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	    CFLAGS='-O2' \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile \
		  || exit 1

	case ${PKGVER} in
	2.1|2.2-rc2)
		[ -r src/common.c ] || mv src/common.c src/common.c.OLD || exit 1
		cat src/common.c.OLD \
			| sed	' s%mbtowc%/* mbtowc */%
				; s%wctomb%/* wctomb */%
				' > src/common.c || exit 1

		[ -r src/minicom.c.OLD ] || mv src/minicom.c src/minicom.c.OLD || exit 1
		cat src/minicom.c.OLD \
			| sed	' s/#include <wchar.h>/#define wchar_t char/
				; /#include <wctype.h>/	s%$% */%
				; /#include <wctype.h>/	s%^%/* %
				' > src/minicom.c || exit 1

		[ -r src/window.c ] || mv src/window.c src/window.c.OLD || exit 1
		cat src/window.c.OLD \
			| sed	' s/#include <wchar.h>/#define wchar_t char/
				' > src/window.c || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
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
