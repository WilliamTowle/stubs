#!/bin/sh
# 16/07/2007

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

	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
		echo "$0: Failed: No zlib.h?" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	1.12.0|1.12.1|1.0.3|1.12.2|1.12.3)
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
	1.13.[15]|1.14.[02]|1.15.[01])
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
			| sed '/^CFLAGS[ 	]*=/	s%-I/usr/local/include%%' \
			> master.make || exit 1

		[ -r ksym_mod.c.OLD ] || mv ksym_mod.c ksym_mod.c.OLD || exit 1
		cat ksym_mod.c.OLD \
			| sed '/LINUX_VERSION_CODE/ s%0x20112%((2<<16)|(0<<8)|(40)) /* 2.0.40 */%' \
			| sed 's/lseek64/lseek/g' \
			| sed 's/off64_t/off_t/g' \
			> ksym_mod.c || exit 1
	;;
	1.0.[45])
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
	1.16.0)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr --bindir=/bin \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --disable-pthreads \
			  || exit 1

		[ -r ksym_mod.c.OLD ] || mv ksym_mod.c ksym_mod.c.OLD || exit 1
		cat ksym_mod.c.OLD \
			| sed '/LINUX_VERSION_CODE/ s%0x20112%((2<<16)|(0<<8)|(40)) /* 2.0.40 */%' \
			| sed 's/lseek64/lseek/g' \
			| sed 's/off64_t/off_t/g' \
			> ksym_mod.c || exit 1

		mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed '/^#define [a-z]*alloc/ { s%^%/* % ; s%$% */% }' \
			> config.h || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	1.0.[45]|1.12.2|1.12.3|1.13.[25]|1.14.[02]|1.15.[01])
		# v0.9.7 introduced subdirectories named by target system
		( cd linux && make ) || exit 1
	;;
	1.16.0)
		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	1.0.[45]|1.12.2|1.12.3|1.13.[25]|1.14.[02]|1.15.[01])
		mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man5/ || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man8/ || exit 1
		( cd linux && make DESTDIR=${INSTTEMP} install ) || exit 1
	;;
	1.16.0)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
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
