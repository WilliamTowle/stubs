#!/bin/sh
# 27/01/2005

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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
		exit 1
	fi

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  ac_cv_sizeof_short=2 \
	  ac_cv_sizeof_int=4 \
	  ac_cv_sizeof_long=4 \
	  ac_cv_sizeof_long_long=8 \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=${FR_LIBCDIR} \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --with-pcap=linux \
		  || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
	;;
*)
	exit 1
	;;
esac
