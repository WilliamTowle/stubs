#!/bin/sh
# 05/02/2006

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
	0.9.5)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC/ s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^	/ s/-[og] ${MAN_OWNER}//g' \
			> Makefile || exit 1
	;;
	0.9.6)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^#*CC/ 	s/^#*//' \
			| sed '/^CC/	s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^	/ s/..VPATH..//' \
			| sed '/^	/ s/..INSTALL./install/' \
			| sed '/^	/ s%..BINDIR.%/usr%' \
			| sed '/^	/ s%..MANDIR.%/usr/man%' \
			> Makefile || exit 1
	;;
	0.9.7|0.9.8)
		[ -r linux/Makefile.OLD ] || mv linux/Makefile linux/Makefile.OLD || exit 1
		cat linux/Makefile.OLD \
			| sed '/^FEATURE_LARGEFILE/ s/=1/=0/' \
			> linux/Makefile || exit 1

		[ -r master.make.OLD ] || mv master.make master.make.OLD || exit 1
		cat master.make.OLD \
			| sed '/^#*CC/ 	s/^#*//' \
			| sed '/^CC/	s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^	/ s%..VPATH.%../%' \
			| sed '/^	/ s/..INSTALL./install/' \
			| sed '/^	/ s%..BINDIR.%/usr%' \
			| sed '/^	/ s%..MANDIR.%/usr/man%' \
			> master.make || exit 1
	;;
	1.0.0|1.0.2|1.10.0|1.10.2|1.11.1)
		[ -r linux/Makefile.OLD ] || mv linux/Makefile linux/Makefile.OLD || exit 1
		cat linux/Makefile.OLD \
			| sed '/^MANDIR/ s%/usr/share%/usr%' \
			| sed '/^FEATURE_LARGEFILE/ s/=1/=0/' \
			> linux/Makefile || exit 1

		[ -r master.make.OLD ] || mv master.make master.make.OLD || exit 1
		cat master.make.OLD \
			| sed '/^#*CC/ 	s/^#*//' \
			| sed '/^CC/	s%gcc%'${FR_CROSS_CC}'%' \
			> master.make || exit 1
	;;
	1.11.0)
		[ -r linux/Makefile.OLD ] || mv linux/Makefile linux/Makefile.OLD || exit 1
		cat linux/Makefile.OLD \
			| sed '/^MANDIR/ s%/usr/share%/usr%' \
			| sed '/^FEATURE_LARGEFILE/ s/=1/=0/' \
			> linux/Makefile || exit 1

		# v1.11.0 builds rfc3195d, but lacks manpage
		[ -r master.make.OLD ] || mv master.make master.make.OLD || exit 1
		cat master.make.OLD \
			| sed '/^#*CC/ 	s/^#*//' \
			| sed '/^CC/	s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^	/ s%..VPATH.%../%' \
			| sed '/^	.*rfc3195d.8/ s/^/#/' \
			> master.make || exit 1
	;;
	1.12.0|1.12.1|1.0.3)
		[ -r linux/Makefile.OLD ] || mv linux/Makefile linux/Makefile.OLD || exit 1
		cat linux/Makefile.OLD \
			| sed '/^MANDIR/ s%share/%%' \
			| sed '/^FEATURE_LARGEFILE/ s/=1/=0/' \
			| sed '/^FEATURE_PTHREADS/ s/=1/=0/' \
			> linux/Makefile || exit 1

		[ -r master.make.OLD ] || mv master.make master.make.OLD || exit 1
		cat master.make.OLD \
			| sed '/^#*CC/ 	s/^#*//' \
			| sed '/^CC/	s%gcc%'${FR_CROSS_CC}'%' \
			> master.make || exit 1
	;;
	1.0.4)
		[ -r linux/Makefile.OLD ] || mv linux/Makefile linux/Makefile.OLD || exit 1
		cat linux/Makefile.OLD \
			| sed '/^MANDIR/ s%share/%%' \
			| sed '/^FEATURE_LARGEFILE/ s/=1/=0/' \
			> linux/Makefile || exit 1

		[ -r master.make.OLD ] || mv master.make master.make.OLD || exit 1
		cat master.make.OLD \
			| sed '/^#*CC/ 	s/^#*//' \
			| sed '/^CC/	s%gcc%'${FR_CROSS_CC}'%' \
			> master.make || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	0.9.5|0.9.6)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make || exit 1
	;;
	0.9.7|0.9.8|1.0.0|1.0.2|1.10.0|1.10.2|1.11.1|1.12.0|1.12.1|1.0.3|1.0.4)
		# v0.9.7 introduced subdirectories named by target system
		( cd linux && make ) || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	0.9.5)
		mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
		mkdir -p ${INSTTEMP}/usr/share/man/man5/ || exit 1
		mkdir -p ${INSTTEMP}/usr/share/man/man8/ || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	0.9.6)
		mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man5/ || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man8/ || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	0.9.7|0.9.8|1.0.0|1.0.2|1.10.0|1.10.2|1.11.1|1.12.0|1.12.1|1.0.3|1.0.4)
		mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man5/ || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man8/ || exit 1
		( cd linux && make DESTDIR=${INSTTEMP} install ) || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
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
