#!/bin/sh
# 23/01/2005

#TODO:- wants libio.h (full g++ compiler suite?)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

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

	TARGET_SYS=${TARGET_CPU}-linux

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CXX=`echo ${FR_CROSS_CC} | sed 's/cc$/++/'` \
		./configure --prefix=${FR_LIBCDIR} \
		  --host=`uname -m` --build=${TARGET_SYS} \
		  || exit 1
echo "FIX GCCINCDIR"
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		# v1.0.4: DEFS has -I in it already :(
		cat ${MF}.OLD \
			| sed '/^DEFS/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include -I'${TCTREE}'/usr/include/g++-3 %' \
			| sed '/^CXXFLAGS/ s/ -g / /' \
			> ${MF} || exit 1
	done || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	make DESTDIR='' install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#	;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
