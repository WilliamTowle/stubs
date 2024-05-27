#!/bin/sh -x
# 2006-06-22 (prev 2005-12-07)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${FR_TARGET_DEFN} in
	i386-*)
		[ -r lib/internal.h.OLD ] || mv lib/internal.h lib/internal.h.OLD || exit 1
		cat lib/internal.h.OLD \
			| sed '/__GNUC__/	{ s%^%#if 0 /* (not uClibc 0.9.20) % ; s%$% */% }' \
			> lib/internal.h || exit 1

		[ -r lib/types.h.OLD ] || mv lib/types.h lib/types.h.OLD || exit 1
		cat lib/types.h.OLD \
			| sed '/__GNUC__/	{ s%^%#if 0 /* (not uClibc 0.9.20) % ; s%$% */% }' \
			> lib/types.h || exit 1

		[ -r lib/sysdep.h.OLD ] || mv lib/sysdep.h lib/sysdep.h.OLD || exit 1
		cat lib/sysdep.h.OLD \
			| sed '/define cpu_to_le16/	s%__cpu_to_le16%/* __cpu_to_le16 */%' \
			| sed '/define cpu_to_le32/	s%__cpu_to_le32%/* __cpu_to_le32 */%' \
			| sed '/define le16_to_cpu/	s%__le16_to_cpu%/* __le16_to_cpu */%' \
			| sed '/define le32_to_cpu/	s%__le32_to_cpu%/* __le32_to_cpu */%' \
			> lib/sysdep.h || exit 1
	;;
	*)
		echo "$0: do_configure(): Unexpected FR_TARGET_DEFN ${FR_TARGET_DEFN}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	2.2.3)
		make PREFIX=/usr/local CC=${FR_CROSS_CC} || exit 1
	;;
	2.2.[456789]|3.0.0)
		make PREFIX=/usr/local CC=${FR_CROSS_CC} ZLIB=no || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected FR_TARGET_DEFN ${FR_TARGET_DEFN}" 1>&2
		exit 1
	;;
	esac

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
