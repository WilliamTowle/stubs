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

	case ${PKGVER} in
	*-ac*)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
	*)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC/ s%gcc%'${FR_CROSS_CC}'%' \
			| sed 's%= /usr/local%= ${DESTDIR}/usr/local%' \
			> Makefile || exit 1
	;;
	esac

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g || exit 1
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/local/man/mann || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_tc_host || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac