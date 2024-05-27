#!/bin/sh
# 27/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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
		FR_KERNSRC=${FR_LIBCDIR}/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ -r /lib/ld-linux.so.1 ] ; then
		FR_HOST_DEFN=`uname -m`-pc-`uname -s | tr A-Z a-z`-gnulibc1
	else
		FR_HOST_DEFN=`uname -m`-pc-`uname -s | tr A-Z a-z`
	fi

	case ${FR_TARGET_DEFN} in
	*uclibc)
		FR_TARGET_DEFN=`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/ ; s/uclibc$/linux/'`
	;;
	esac

	if [ -r /lib/ld-linux.so.1 ] ; then
		# provided 'install' script assumes we have bash :(
		FR_INSTALL=`PATH=${FR_TH_ROOT}/bin:${PATH} which install`
		if [ -z "${FR_INSTALL}" ] ; then
			echo "$0: Confused - No 'install'" 1>&2
			exit 1
		fi

		# (26/03/2005) PATH needs cmp,diff,flex
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  ac_cv_sizeof_long_long=8 \
		  ac_cv_path_install=${FR_INSTALL} \
		  CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${FR_TC_ROOT}/usr \
			  --host=${FR_HOST_DEFN} \
			  --build=${FR_HOST_DEFN} \
			  --target=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  --disable-long-long \
			  --disable-werror \
			  || exit 1
	else
		# (26/03/2005) PATH needs cmp,diff,flex
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${FR_TC_ROOT}/usr \
			  --host=${FR_HOST_DEFN} \
			  --build=${FR_HOST_DEFN} \
			  --target=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  --disable-long-long \
			  --disable-werror \
			  || exit 1
	fi

# BUILD...
	# (26/03/2005) PATH needs (f)lex
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  make || exit 1

# INSTALL...
	make install || exit 1

	# ...preserve an assembler for kernel builds:
	( cd ${FR_TC_ROOT}/usr/bin || exit 1
		for EXE in addr2line ar as \
			c++filt ld nm objcopy objdump \
			ranlib readelf size strings strip ; do

#			ln -sf ${FR_TARGET_DEFN}-${EXE} `echo ${FR_TARGET_DEFN}-${EXE} | sed 's/cross/minimal/'`
			ln -sf ${FR_TARGET_DEFN}-${EXE} `echo ${FR_TARGET_DEFN}-${EXE} | sed 's/-[^-]*-/-kernel-/'`
		done
		true
	) || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
