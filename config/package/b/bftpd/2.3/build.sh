#!/bin/sh -x
# from INCOMING 2008-04-04

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1

	case ${PKGVER} in
	2.3)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CFLAGS[ 	]*=/	s/-D_FILE_OFFSET_BITS=64//' \
			| sed '/^	/	s%/var%${DESTDIR}/var%' \
			> Makefile || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

#	if [ -r config.h ] ; then
#		echo "config.h found" 1>&2
#		exit 1
##		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
##		cat config.h.OLD \
##			| sed '/HAVE_WCHAR_H/	s%^/\* %%' \
##			| sed '/HAVE_WCHAR_H/	s% \*/$%%' \
##			| sed '/HAVE_WCHAR_T/	s%define%undef%' \
##			| sed '/HAVE_WCHAR_T/	s% 1%%' \
##			| sed '/HAVE_WCTYPE_H/	s%^/\* %%' \
##			| sed '/HAVE_WCTYPE_H/	s% \*/$%%' \
##			> config.h || exit 1
#	fi

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LIBC_NCURSES} || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/man/ || exit 1
	mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
	mkdir -p ${INSTTEMP}/var/log/ || exit 1
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
