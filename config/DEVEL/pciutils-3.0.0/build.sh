#!/bin/sh
# 07/12/2005

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

	case ${TARGET_CPU} in
	i386)	;;
	*)	echo "$0: CONFIGURE: Unsupported TARGET_CPU ${TARGET_CPU}" 1>&2
		exit 1
	;;
	esac

	[ -r lib/sysdep.h.OLD ] || mv lib/sysdep.h lib/sysdep.h.OLD || exit 1
	cat lib/sysdep.h.OLD \
		| sed '/define cpu_to_le16/	s/__cpu_to_le16//' \
		| sed '/define cpu_to_le32/	s/__cpu_to_le32//' \
		| sed '/define le16_to_cpu/	s/__le16_to_cpu//' \
		| sed '/define le32_to_cpu/	s/__le32_to_cpu//' \
		> lib/sysdep.h || exit 1

# BUILD...
	make PREFIX=/usr/local CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	make PREFIX=${INSTTEMP}/usr/local install
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
