#!/bin/sh
# 23/02/2006

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
	2.9)
		for MF in `find ./ -name Makefile` ; do
			[ -r $MF.OLD ] || mv $MF $MF.OLD || exit 1
			cat $MF.OLD \
				| sed '/^CC/ s/gcc/${CCPREFIX}cc/' \
				| sed 's/ln -s/ln -sf/' \
				> $MF || exit 1
		done

#		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#		cat Makefile.OLD \
#			| sed '/^CC[ 	]=/	s%g*cc%'${FR_CROSS_CC}'%' \
#			> Makefile || exit 1
	;;
	2.10)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC[ 	]=/	s%g*cc%'${FR_CROSS_CC}'%' \
			> Makefile || exit 1

		for SF in dosfsck.h file.c ; do
			[ -r dosfsck/${SF}.OLD ] || mv dosfsck/${SF} dosfsck/${SF}.OLD || exit 1
			cat dosfsck/${SF}.OLD \
				| sed '/msdos_fs/ s%^%#include <asm/types.h>\n%' \
				> dosfsck/${SF} || exit 1
		done
	;;
	2.11)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC[ 	]=/	s%g*cc%'${FR_CROSS_CC}'%' \
			| sed '/^OPTFLAGS[ 	]=/	s/-D_FILE_OFFSET_BITS=64//' \
			> Makefile || exit 1

		for SF in dosfsck.h file.c ; do
			[ -r dosfsck/${SF}.OLD ] || mv dosfsck/${SF} dosfsck/${SF}.OLD || exit 1
			cat dosfsck/${SF}.OLD \
				| sed '/msdos_fs/ s%^%#include <asm/types.h>\n%' \
				> dosfsck/${SF} || exit 1
		done
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	2.9)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  || exit 1
#		make || exit 1
	;;
	2.10|2.11)
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	2.9|2.10|2.11)
		# (30/01/2005) Needs 'install' PATHed
		PATH=${FR_TH_ROOT}/bin:${PATH} \
			make PREFIX=${INSTTEMP} install || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
