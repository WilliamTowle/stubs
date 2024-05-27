#!/bin/sh
# 01/01/2005

#TODO:- "storage size of geob isn't known" (kernel version?)
#TODO:- "implicit declaration of open()"

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

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile \
		  || exit 1
echo "FIX GCCINCDIR"
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^DEFS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
			> ${MF} || exit 1
	done || exit 1

	[ -r src/main.c.OLD ] || mv src/main.c src/main.c.OLD
	cat src/main.c.OLD \
		| sed '/nr_inodes/ s/unsigned long/int/' \
		| sed '/open(/ s%O_LARGEFILE%0 /*O_LARGEFILE*/%' \
		| sed 's/BLKGETSIZE64/BLKGETSIZE/' \
		| sed 's/HDIO_GETGEO_BIG/HDIO_GETGEO/' \
		| sed 's/fstat64/fstat/' \
		> src/main.c || exit 1

	[ -r src/main.h.OLD ] || mv src/main.h src/main.h.OLD
	cat src/main.h.OLD \
		| sed '/nr_inodes/ s/unsigned long/int/' \
		> src/main.h || exit 1

	[ -r src/config.h.OLD ] || cp src/config.h src/config.h.OLD
	cat src/config.h.OLD \
		| sed 's%I_CHECKED_CONFIG 0%I_CHECKED_CONFIG 1%' \
		> src/config.h

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_tc || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
