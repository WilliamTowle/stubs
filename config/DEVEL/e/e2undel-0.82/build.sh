#!/bin/sh
# 09/04/2004

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

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/ s%gcc%${CCPREFIX}cc -D_EXT2_TYPES_H%' \
			| sed '/^	/ s%gcc%$(CC)%' \
			> ${MF} || exit 1
	done || exit 1

	[ -r e2undel.c.OLD ] || mv e2undel.c e2undel.c.OLD || exit 1
	cat e2undel.c.OLD \
		| sed '/_FILE_OFFSET_BITS/ s/64/32/' \
		> e2undel.c || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	#make prefix=${INSTTEMP}/usr install
	mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
	cp e2undel ${INSTTEMP}/usr/sbin || exit 1
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
