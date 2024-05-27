#!/bin/sh -x
# 2008-07-07

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	1.1.4)
		CC=${FR_CROSS_CC} \
			./configure --prefix=${FR_LIBCDIR} \
			  --host=`uname -m`-misc-linux-gnu --build=${TARGET_CPU}-uclibc-linux \
			  --disable-malloc0returnsnull \
			  XPROTO_CFLAGS=' ' XPROTO_LIBS=' ' \
			  X11_CFLAGS=' ' X11_LIBS=' ' \
			  XKBPROTO_CFLAGS=' ' XKBPROTO_LIBS=' ' \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	case ${USE_DISTRO}-${FR_TARGET_DEFN} in
	fr*uclibc)
#		# adjust source[s] for uClibc - wide character support
#		[ -r xc/lib/X11/Xlib.h.OLD ] || mv xc/lib/X11/Xlib.h xc/lib/X11/Xlib.h.OLD || exit 1
#		cat xc/lib/X11/Xlib.h.OLD \
#			| sed '/defined(ISC)/ s/defined.*/1/' \
#			| sed '/define mbtowc/ { s%^%/* % ; s%$% */% }' \
#			| sed '/define mblen/ s%$%\n#define mbtowc(a,b,c) _Xmbtowc(a,b,c)\n#define mbstowcs(a,b,c) _Xmbstowcs(a,b,c)%' \
#			> xc/lib/X11/Xlib.h || exit 1 

#			xc/programs/Xserver/Xprint/Init.c \
#			xc/programs/Xserver/Xprint/attributes.c \
		for SF in \
			modules/lc/gen/lcGenConv.c \
		 ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
				| sed 's/wchar_t/char/' \
				| sed 's%mbtowc%(char)/*mbtowc*/%' \
				> ${SF} || exit 1
		done

		[ -r src/Makefile.in.OLD ] || mv src/Makefile.in src/Makefile.in.OLD || exit 1
		cat src/Makefile.in.OLD \
			| sed '/^	/ s/makekeys < /makekeys.host < /' \
			> src/Makefile.in || exit 1

#		# adjust source[s] for uClibc - large file support
#		for SF in \
#			xc/programs/Xserver/hw/xfree86/etc/mmapr.c \
#			xc/programs/Xserver/hw/xfree86/etc/mmapw.c \
#		; do
#			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
#			cat ${SF}.OLD \
#				| sed '/define _FILE_OFFSET/	s/64/32/' \
#				> ${SF} || exit 1
#		done
	;;
	*)
		echo "$0: CONFIGURE: Unexpected USE_DISTRO/FR_TARGET_DEFN ${USE_DISTRO}, ${FR_TARGET_DEFN}"
		exit 1
	;;
	esac
}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/X11/X.h ] ; then
		echo "$0: X.h missing (build xorg-x11proto-core)" 1>&2
		exit 1
	fi

	PHASE=tc do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	1.1.4)
		make -C src/util CC=${FR_HOST_CC} makekeys 2>&1 || exit 1
		mv src/util/makekeys src/util/makekeys.host || exit 1
		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	1.1.4)
		make install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-cross)
	make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
