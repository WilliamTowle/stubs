#!/bin/sh
# 18/11/2006

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

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in gentoo-antiword/patches/* ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC	/	s/=.*/= ${CCPREFIX}cc/' \
		| sed '/^LD	/	s/=.*/= ${CCPREFIX}cc/' \
		> Makefile || exit 1

	[ -r chartrans.c.OLD ] || mv chartrans.c chartrans.c.OLD || exit 1
	cat chartrans.c.OLD \
		| sed '/#include <wctype.h>/ s%^%/* %' \
		| sed '/#include <wctype.h>/ s%$% */%' \
		| sed '/#include <wctype.h>/ s%.*%#undef __STDC_ISO_10646__%' \
		> chartrans.c || exit 1

# BUILD...

		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} global_install || exit 1
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
