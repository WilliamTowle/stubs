#!/bin/sh
# 2007-08-31

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

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	else
		echo "$0: make_dc(): No (n)curses built" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/lib/libpcre.a ] ; then
		echo "$0: make_dc(): No (lib)pcre built" 1>&2
		exit 1
	fi

#	case ${PKGVER} in
#	1.0b[89]|1.0b10)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1

		[ -r src/config.h.OLD ] || mv src/config.h src/config.h.OLD || exit 1
		cat src/config.h.OLD \
			| sed	' /HAVE_TERMCAP_H/	s%1%/* 1 */%
				; /HAVE_TERMCAP_H/	s%define%undef%
				; /HAVE_GETLOADAVG/	s%1%/* 1 */%
				; /HAVE_GETLOADAVG/	s%define%undef%
				' > src/config.h || exit 1

		find ./ -name Makefile | while read MF ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /^LIBS[ 	]/	s/-ltermcap/-lncurses/
					' > ${MF} || exit 1
		done
#	;;
#	*)
#		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#	;;
#	esac

## | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/-g//' \
#			> ${MF} || exit 1
#	done

# BUILD...
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
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
