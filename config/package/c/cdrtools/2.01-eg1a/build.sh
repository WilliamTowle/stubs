#!/bin/sh
# 15/06/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
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

#cat <EOF
##TODO:- gets dependency generation wrong wrt kernel location! FIXME!!
#EOF
# CONFIGURE...
	[ -r DEFAULTS/Defaults.linux.OLD ] || mv DEFAULTS/Defaults.linux DEFAULTS/Defaults.linux.OLD
	cat DEFAULTS/Defaults.linux.OLD \
		| sed '/DEFCCOM/ { s/^/#/ ; s%gcc$%'${FR_CROSS_CC}'% ; /gcc/ s/^#// }' \
		| sed '/^INS_BASE=/	s%/.*%/usr%' \
		| sed '/^INS_KBASE=/	s%/.*%/usr%' \
		> DEFAULTS/Defaults.linux
	( cd RULES && ln -sf ${TARGET_CPU}-linux-gcc.rul `uname -m`-linux-${TARGET_CPU}-uclibc-gcc.rul ) || exit 1

# BUILD...
#	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH}
		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	[ -r DEFAULTS/Defaults.linux.OLD ] || mv DEFAULTS/Defaults.linux DEFAULTS/Defaults.linux.OLD
	cat DEFAULTS/Defaults.linux.OLD \
		| sed '/^INS_BASE=/	s%/.*%'${FR_TH_ROOT}'/usr%' \
		| sed '/^INS_KBASE=/	s%/.*%'${FR_TH_ROOT}'/usr%' \
		> DEFAULTS/Defaults.linux

	make || exit 1
	make install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
