#!/bin/sh -x
# 14/12/2006

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

	if [ ! -d ${FR_LIBCDIR}/err_h ] ; then
		echo "No Kragen's err.h build" 1>&2
		exit 1
	else
		DIR_KRAGENSERRH=${FR_LIBCDIR}/err_h
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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
