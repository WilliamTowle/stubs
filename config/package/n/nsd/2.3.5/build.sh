#!/bin/sh
# 04/06/2006

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

	# ver 2.2.0 and up? (20/01/2005)
	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
		echo "No libssl build" 1>&2
		exit 1
	else
		CONFIGURE_SSL="--with-ssl=${FR_LIBCDIR}"
	fi

	case ${PKGVER} in
##	PATH=${FR_LIBCDIR}/bin:${PATH}
#	  CC=${FR_CROSS_CC} \
#	  CFLAGS="-O2" \
#		./configure --prefix= \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls --disable-largefile \
#		  --without-libwrap \
#		  --with-ssl=${FR_LIBCDIR} \
#		  || exit 1
#
##	case ${PKGVER} in
##	2.3.4)
##		# | sed '/^prefix/ s%/%${DESTDIR}/%' \
##		for MF in `find ./ -name Makefile` ; do
##			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
##			cat ${MF}.OLD \
##				| sed '/^CFLAGS/ s/ -g / /' \
##				> ${MF} || exit 1
##		done
##	;;
##	esac
##	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
##	cat config.h.OLD \
##		| sed '/define LIBWRAP/	s/define/undef/' \
##		> config.h || exit 1
	2.3.5)
		  CC=${FR_CROSS_CC} \
		    CFLAGS="-O2" \
			./configure --prefix= \
			  --build=`uname -m` --host=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --without-libwrap \
			  ${CONFIGURE_SSL} \
			  || exit 1

		# (2.3.5) LIBWRAP undefined by default :)
		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed	' /define HAVE_LIBCRYPTO/	s/ 1//
				; /define HAVE_LIBCRYPTO/	s/define/undef/
				' > config.h || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
