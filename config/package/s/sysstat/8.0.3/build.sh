#!/bin/sh
# 2007-11-19

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

	case ${PKGVER} in
	7.0.4)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
			> Makefile || exit 1
	;;
	7.1.1|7.1.2)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
	;;
	8.0.[013])
		if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
			echo "$0: Aborting -- no 'fakeroot'" 1>&2
			exit 1
		fi

		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	7.0.4)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make REQUIRE_NLS='' \
			  CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  || exit 1
	;;
	7.1.1|7.1.2)
		make || exit 1
	;;
	8.0.[013])
		make || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	7.0.4)
		mkdir -p ${INSTTEMP}/var/log/sa || exit 1
		make DESTDIR=${INSTTEMP} IGNORE_MAN_GROUP=y REQUIRE_NLS='' \
		  install || exit 1
	;;
	7.1.1|7.1.2)
		make DESTDIR=${INSTTEMP} install \
	;;
	8.0.[013])
		${FR_TH_ROOT}/usr/bin/fakeroot \
			-- make DESTDIR=${INSTTEMP} install
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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
