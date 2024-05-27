#!/bin/sh -x
# 2008-03-02

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
	8.6)
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
	8.6)
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
