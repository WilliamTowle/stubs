#!/bin/sh
# 2008-01-05

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

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  ac_cv_header_curses_h=yes \
	  ac_cv_header_ncurses_h=yes \
	  ac_cv_header_term_h=yes \
	  ac_cv_header_termcap_h=yes \
	  CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-lfs --disable-locale --disable-nls \
		  --disable-shared \
		  --disable-dynamic-nss \
		  || exit 1

	case ${PKGVER} in
	4.2.[57]|4.3.[269])
		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed '/define MULTIBYTE_SUPPORT/ { s/.*define/#undef/ ; s/ 1// }' \
			| sed '/CONFIG_LOCALE/	{ s%/\* %% ; s% \*/%% }' \
			| sed '/define HAVE_ICONV/ { s/.*HAVE/#undef HAVE/ ; s/ 1// }' \
			| sed '/define HAVE_WCTOMB/ { s/.*HAVE/#undef HAVE/ ; s/ 1// }' \
			> config.h || exit 1

		# CODESET change eliminates ucs4toutf8() call
		[ -r Src/utils.c.OLD ] || mv Src/utils.c Src/utils.c.OLD || exit 1
		cat Src/utils.c.OLD \
			| sed '/;/ s%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
			| sed 's/(CODESET)$/(CODESET) \&\& !defined (__STDC_ISO_10646__)/' \
			> Src/utils.c || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^LIBS/ s/termcap/ncurses/' \
				> ${MF} || exit 1
		done
	;;
	*)	echo "Confused -- unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

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
