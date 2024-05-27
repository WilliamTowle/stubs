#!/bin/sh
# 2008-07-17 (EARLIEST v0.0.7, c.2004-01-29)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
		echo "No libssl build" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	1.0.10)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CFLAGS=/ s/ *$(DEBUG)//' \
			| sed '/^	/ s%share/%%' \
			> Makefile || exit 1
	;;
	1.2.[12]|1.2.4|1.2.[89])
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed	' /^CFLAGS=/ s/ *$(DEBUG)//
				; /^LDFLAGS=/ s/ *$(DEBUG)//
				; /^	/ s%share/%%
				' > Makefile || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	1.0.10)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make CC=${FR_CROSS_CC} || exit 1
	;;
	1.2.[12]|1.2.4|1.2.[89])
		make CC=${FR_CROSS_CC} || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
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
