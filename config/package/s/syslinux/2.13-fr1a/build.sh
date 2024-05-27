#!/bin/sh
# 09/02/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_prelim()
{
# Makefile adjust:
	case ${PHASE}-${PKGVER} in
	dc-2.1?)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed 's/copybs.com //' \
			| sed 's/syslinux.com //' \
			| sed 's/syslinux.exe //' \
			| sed 's/-D_FILE_OFFSET_BITS=64//' \
			> Makefile || exit 1

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
		;;
	th-2.1?)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed 's/copybs.com //' \
			| sed 's/syslinux.com //' \
			| sed 's/syslinux.exe //' \
			> Makefile || exit 1

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
		;;
	dc-3.0?)	# 3.09 ... and earlier?
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
				| sed '/^CFLAGS/ s/-D_FILE_OFFSET_BITS=64//' \
				| sed '/^	/ s/-Wp,.*.d //' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
		;;
	dc-3.*)	# 3.10 ... and later?
		# v3.10 needs not to compile at 'install' step
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
				| sed '/^CFLAGS/ s/-D_FILE_OFFSET_BITS=64//' \
				| sed '/^	/ s/-Wp,.*.d //' \
				| sed '/^install:/	s/installer//' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
		;;
	th-3.*)
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
				| sed '/^	/ s/-Wp,.*.d //' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
		;;
	esac

# Source files adjust:
	if [ "${PHASE}" = 'dc' ] ; then
		case ${PKGVER} in
		2.1?)
			[ -r syslinux-nomtools.c.OLD ] || mv syslinux-nomtools.c syslinux-nomtools.c.OLD || exit 1
			cat syslinux-nomtools.c.OLD \
				| sed 's%#define _LARGEFILE64_SOURCE.*%//#define _LARGEFILE64_SOURCE...%' \
				| sed 's%|O_LARGEFILE%/* | O_LARGEFILE */%' \
				> syslinux-nomtools.c || exit 1
			;;
		3.*)
			[ -r unix/syslinux.c.OLD ] || mv unix/syslinux.c unix/syslinux.c.OLD || exit 1
			cat unix/syslinux.c \
				| sed '/define _FILE_OFFSET_BITS/ s%^%//%' \
				> unix/syslinux.c || exit 1
			;;
		esac
	fi
}

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

	( PHASE=dc do_prelim ) || exit 1

# BUILD...
	case ${PKGVER} in
	2.*)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  all || exit 1
		;;
	3.*)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  installer || exit 1
		;;
	esac

# INSTALL...
	make INSTALLROOT=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
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

	if [ -r ${FR_TH_ROOT}/usr/bin/nasm ] ; then
		FR_NASM=${FR_TH_ROOT}/usr/bin/nasm
	else
		echo "$0: Aborting: No 'nasm' built" 1>&2
		exit 1
	fi

	( PHASE=th do_prelim ) || exit 1

# BUILD...
	case ${PKGVER} in
	2.*)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			make CC=${FR_HOST_CC} all || exit 1
		;;
	3.*)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			installer || exit 1
		;;
	esac

# INSTALL...
	make CCPREFIX=`echo ${FR_HOST_CC} | sed 's/cc$//'` \
		INSTALLROOT=${FR_TH_ROOT} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
