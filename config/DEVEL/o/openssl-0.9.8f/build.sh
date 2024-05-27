#!/bin/sh
# 2007-11-04

# v0.9.8[a-c]: Various crypto/bio files problematic

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		./config shared `echo ${TARGET_CPU} | sed 's/i//'` \
		  --prefix=/usr \
		  || exit 1

	case ${PKGVER} in
	0.9.7[ckl])
		# needs additional hack to fix pkgconfig-related problems
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^CFLAG *=/ s/-m486/-march='${TARGET_CPU}'/' \
				| sed '/^PROCESSOR *=/ s/=.*/='${TARGET_CPU}'/' \
				| sed '/^	.*pkgconfig$/ s/chmod 644/chmod 755/' \
				> ${MF} || exit 1
		done
	;;
	0.9.7m)
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^CFLAG *=/ s/-m486/-march='${TARGET_CPU}'/' \
				| sed '/^CFLAG *=/ s/$/ -D_FILE_OFFSET_BITS=32/' \
				| sed '/^PROCESSOR *=/ s/=.*/='${TARGET_CPU}'/' \
				> ${MF} || exit 1
		done
	;;
	0.9.8[ef])
		# v0.9.8a wants _FILE_OFFSET_BITS for 'bss' crypto
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^CFLAG *=/ s/$/ -D_FILE_OFFSET_BITS=32 -DOPENSSL_NO_BIO/' \
				| sed '/^PROCESSOR *=/ s/=.*/='${TARGET_CPU}'/' \
				> ${MF} || exit 1
		done

		for SF in crypto/bio/bio.h crypto/bio/bss_dgram.c ; do
			[ -r ${SF} ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's%ifndef OPENSSL_NO_DGRAM%if 0 /* OPENSSL_NO_DGRAM */%' \
				> ${SF} || exit 1
		done
	;;
	*)
		echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
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

	do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make INSTALL_PREFIX=${INSTTEMP} install || exit 1
}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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

	do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make INSTALL_PREFIX=${FR_LIBCDIR} INSTALLTOP='' install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
