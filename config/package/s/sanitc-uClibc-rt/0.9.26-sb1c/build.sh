#!/bin/sh
# 25/02/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	cp ${TCTREE}/etc/${USE_TOOLCHAIN}/uClibc-${PKGVER}-config .config || exit 1
	yes '' | make HOSTCC=${FR_HOST_CC} oldconfig \
		  || exit 1

#	mv extra/gcc-uClibc/gcc-uClibc.c extra/gcc-uClibc/gcc-uClibc.c.OLD || exit 1
#	cat extra/gcc-uClibc/gcc-uClibc.c.OLD \
#		| sed	' /strlen(cc);/	s%$% */%
#			; /strlen(cc);/	s%(cc)%("'${FR_TC_ROOT}'/usr/bin/'${TARGET_CPU}'-linux-2.7.2.3-gnu-kgcc"); /* (cc)%
#			; /strdup(cc);/	s%$% */%
#			; /strdup(cc);/	s%(cc)%("'${FR_TC_ROOT}'/usr/bin/'${TARGET_CPU}'-linux-2.7.2.3-gnu-kgcc"); /* (cc)%
#			' > extra/gcc-uClibc/gcc-uClibc.c || exit 1

	[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1
	cat Rules.mak.OLD \
		| sed	' /^CROSS/	s%=.*%= '${FR_TC_ROOT}'/usr/bin/'`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-[^-]*/-kernel-linux/'`'-% ; /(CROSS)/	s%$(CROSS)%$(shell if [ -n "${CROSS}" ] ; then echo ${CROSS} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$//'`'" ; fi)% ; /USE_CACHE/ s/#//' \
		> Rules.mak || exit 1
	for MF in libc/sysdeps/linux/*/Makefile ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's/-g,,/-g , ,/' \
			> ${MF} || exit 1
	done
	case ${PKGVER} in
	0.9.20)
		[ -r ldso/util/Makefile.OLD ] || mv ldso/util/Makefile ldso/util/Makefile.OLD || exit 1
		cat ldso/util/Makefile.OLD \
			| sed 's%$(HOSTCC)%'${HTC_GCC}'%' \
			> ldso/util/Makefile || exit 1
		[ -r ldso/util/bswap.h.OLD ] || mv ldso/util/bswap.h ldso/util/bswap.h.OLD || exit 1
		cat ldso/util/bswap.h.OLD \
			| sed 's%def __linux__%def __glibc_linux__ /* __linux__ */%' \
			| sed 's/<string.h>/"stdint.h"/'
			> ldso/util/bswap.h || exit 1
	;;
	0.9.22|0.9.24|0.9.26) ;;
	*)	echo "$0: do_configure 'Makefile's: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	PHASE=dc do_configure

# BUILD...
	case ${PKGVER} in
	0.9.20)
		make || exit 1
		make CROSS=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}- \
			HOSTCC=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc \
			-C ldso/util ldconfig || exit 1
	;;
	0.9.22|0.9.24|0.9.26)
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

## INSTALL...
	case ${PKGVER} in
	0.9.20)
		make PREFIX=${INSTTEMP} install_target || exit 1
		cp ldso/util/ldconfig ${INSTTEMP}/sbin || exit 1
	;;
	0.9.22|0.9.24|0.9.26)
		make PREFIX=${INSTTEMP} install_runtime || exit 1
	;;
	*)	echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
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
