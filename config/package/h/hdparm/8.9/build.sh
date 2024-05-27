#!/bin/sh -x
# 2008-06-19

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	5.[56789])
		[ -r hdparm.c.OLD ] || mv hdparm.c hdparm.c.OLD || exit 1
		cat hdparm.c.OLD \
			| sed 's%__le16_to_cpus%// UNDEFINED - __le16_to_cpus%' \
			> hdparm.c || exit 1

		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC / s/gcc/${CCPREFIX}cc/' \
			| sed '/^binprefix/ s%/.*%/usr%' \
			> Makefile || exit 1
	;;
	# 6.0-6.5 don't cross-compile without patching
	6.6|6.9)
		[ -r hdparm.c.OLD ] || mv hdparm.c hdparm.c.OLD || exit 1
		cat hdparm.c.OLD \
			| sed 's%__le16_to_cpus%// UNDEFINED - __le16_to_cpus%' \
			> hdparm.c || exit 1
	;;
	#8.6
	8.[89])
		case ${FR_TARGET_DEFN} in
		i386-*)
			[ -r hdparm.c.OLD ] || mv hdparm.c hdparm.c.OLD || exit 1
			cat hdparm.c.OLD \
				| sed 's%__le16_to_cpus%/* __le16_to_cpus */%' \
				> hdparm.c || exit 1
		;;
		*)
			echo "$0: CONFIGURE: Unexpected FR_TARGET_DEFN ${FR_TARGET_DEFN}" 1>&2
			exit 1
		;;
		esac

		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/ifndef CC/,+3 { /if/ s/^/#/ ; s%g*cc%'${FR_CROSS_CC}'% }' \
			| sed '/^binprefix[ 	]*=/ s%/.*%/usr%' \
			> Makefile || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
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
	5.[56789])
		# PATH=${FR_LIBCDIR}/bin:${PATH} \...
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		  || exit 1
	;;
	6.6|6.9)
		make CC=${FR_CROSS_CC} \
		  || exit 1
	;;
	8.[89])
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/sbin || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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
