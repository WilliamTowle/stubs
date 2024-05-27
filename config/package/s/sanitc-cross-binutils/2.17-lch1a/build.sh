#!/bin/sh -x
# 31/05/2007

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
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

##	FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
#	if [ -r /lib/ld-linux.so.1 ] ; then
#		FR_HOST_DEFN=`uname -m`-pc-`uname -s | tr A-Z a-z`-gnulibc1
#	else
#		FR_HOST_DEFN=`uname -m`-pc-`uname -s | tr A-Z a-z`
#	fi
##	FR_TARGET_DEFN=${TARGET_CPU}-cross-linux
#	FR_TARGET_DEFN=`echo ${FR_HOST_DEFN} | sed 's/[^-]*/'${TARGET_CPU}'/' | sed 's/pc/cross/'`

	if [ -d uclibc-patches ] ; then
		echo "...Patching [Gentoo]..."
		for PF in uclibc-patches/*patch ; do
			patch --batch -d binutils-${PKGVER} -Np1 < ${PF} || exit 1
		done
	else
		echo "...Patching [LFS]..."
		for PF in *patch ; do
			patch --batch -d binutils-${PKGVER} -Np1 < ${PF} || exit 1
		done
	fi

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
			./binutils-${PKGVER}/configure -v \
			  --prefix=${FR_TC_ROOT}/usr \
			  --host=${FR_HOST_DEFN} \
			  --target=${FR_TARGET_DEFN} \
		  --program-prefix=${FR_TARGET_DEFN}- \
		  --with-sysroot=${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}-ulibc/ \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1
#		  --with-sysroot=/
#		  --disable-werror
	else
		# (26/03/2005) PATH needs cmp,diff,flex
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./binutils-${PKGVER}/configure -v \
			  --prefix=${FR_TC_ROOT}/usr \
			  --host=${FR_HOST_DEFN} \
			  --target=${FR_TARGET_DEFN} \
		  --program-prefix=${FR_TARGET_DEFN}- \
			  --with-sysroot=/ \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1
#		  --disable-werror
	fi

# BUILD...
	# (26/03/2005) PATH needs (f)lex
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  make || exit 1

# INSTALL...
	# (16/09/2006) `make install` needs appropriate ranlib
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make install || exit 1

	# ...this assembler also suits kernel builds:
	mkdir -p ${FR_TC_ROOT}/usr/`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`/bin || exit 1
	for EXE in addr2line ar as \
		c++filt ld nm objcopy objdump \
		ranlib readelf size strings strip ; do

		( cd ${FR_TC_ROOT}/usr/bin && ln -sf ${FR_TARGET_DEFN}-${EXE} `echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`-${EXE} ) || exit 1
		if [ -r ${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}/bin/${EXE} ] ; then
			( cd ${FR_TC_ROOT}/usr/`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`/bin && ln -sf ../../${FR_TARGET_DEFN}/bin/${EXE} ./ ) || exit 1
		fi
	done
	true
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
