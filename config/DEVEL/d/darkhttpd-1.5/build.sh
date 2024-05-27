#!/bin/sh -x
# 14/12/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -d ${FR_LIBCDIR}/include/err_h ] ; then
		echo "No Kragen's err.h build" 1>&2
		exit 1
	else
		DIR_KRAGENSERRH=${FR_LIBCDIR}/include/err_h
		ADD_INCL_KRAGENSERRH=-I${DIR_KRAGENSERRH}
		ADD_LIBS_KRAGENSERRH=-lerr
	fi

	case ${PKGVER} in
#	1.3)
#		[ -r darkhttpd.c.OLD ] || mv darkhttpd.c darkhttpd.c.OLD || exit 1
#		cat darkhttpd.c.OLD \
#			| sed 's/__linux/__REGULAR_linux/'
#			> darkhttpd.c || exit 1
#
#		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#		cat Makefile.OLD \
#			| sed	' /^[A-Z]/		s/?/:/
#				; /^CC[ 	:]*=/	s%g*cc%'${FR_CROSS_CC}'%
#				' > Makefile || exit 1
#	;;
	1.5)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed	' /^[A-Z]/		s/?/:/
				; /^CC[ 	:]*=/	s%g*cc%'${FR_CROSS_CC}'%
				; /^CFLAGS[ 	:]*=/	s%$% '${ADD_INCL_KRAGENSERRH}'%
				; /^LIBS[ 	:]*=/	s%`.*`% '${ADD_LIBS_KRAGENSERRH}'%
				' > Makefile || exit 1

		[ -r darkhttpd.c.OLD ] || mv darkhttpd.c darkhttpd.c.OLD || exit 1
		cat darkhttpd.c.OLD \
			| sed '/__linux/ { /BSD/ ! s/__linux/__REGULAR_linux/ } '
			> darkhttpd.c || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	1.3)
		make `uname -s | tr A-Z a-z` || exit 1
	;;
	1.5)
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
#	#mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
#	make DESTDIR=${INSTTEMP} install || exit 1
	mkdir -p ${INSTTEMP}/usr/local/sbin || exit 1
	cp darkhttpd ${INSTTEMP}/usr/local/sbin/ || exit 1
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
