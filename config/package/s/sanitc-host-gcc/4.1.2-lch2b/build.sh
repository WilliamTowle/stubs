#!/bin/sh -x
# 30/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d uclibc ] ; then
		echo "...Patching [Gentoo]..."
		for PF in uclibc/*patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
	elif [ ${PKGVER} = '4.1.2' ] ; then
		echo "...Patching [LFS]..."
		for PF in *patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
	fi

	case ${PHASE} in
	dc)
		CC=${FR_CROSS_CC} \
		  CC_FOR_BUILD=${FR_HOST_CC} \
		  HOSTCC=${FR_HOST_CC} \
		  GCC_FOR_TARGET=${FR_CROSS_CC} \
	  	  AR=`echo ${FR_CROSS_CC} | sed 's/gcc/ar/'` \
	  	  AS=`echo ${FR_CROSS_CC} | sed 's/gcc/as/'` \
	  	  LD=`echo ${FR_CROSS_CC} | sed 's/gcc/ld/'` \
	  	  NM=`echo ${FR_CROSS_CC} | sed 's/gcc/nm/'` \
	  	  RANLIB=`echo ${FR_CROSS_CC} | sed 's/gcc/ranlib/'` \
	    	  CFLAGS=-O2 \
			./gcc-${PKGVER}/configure \
			  --prefix=/usr \
			  --host=`echo ${FR_HOST_DEFN} | sed 's/-gnulibc1$/-gnu/'` \
			  --build=${FR_TARGET_DEFN} \
			  --target=${FR_TARGET_DEFN} \
			  --enable-clocale=uclibc \
			  --program-prefix="''" \
			  --with-sysroot=/ \
			  --enable-languages=c \
			  --disable-__cxa_atexit \
			  --disable-nls \
			  --disable-libmudflap \
			  --disable-libssp \
			  --enable-shared \
			  --with-gnu-as \
			  --with-gnu-ld \
			  || exit 1
	;;
	th)
		HAVE_GLIBC_SYSTEM=`if [ -r /lib/libc.so.6 ] ; then echo y ; else echo n ; fi`

		if [ ${HAVE_GLIBC_SYSTEM} = 'y' ] ; then
			PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			  CC=${FR_HOST_CC} \
				./gcc-${PKGVER}/configure -v \
				  --prefix=${FR_TH_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --target=${FR_HOST_DEFN} \
				  --with-sysroot=/ \
				  --enable-languages=c \
				  --disable-nls \
				  --disable-libmudflap \
				  --disable-libssp \
				  --enable-shared \
				  --with-gnu-as \
				  --with-gnu-ld \
				  || exit 1
		else
			CC=${FR_HOST_CC} \
				./gcc-${PKGVER}/configure -v \
				  --prefix=${FR_TH_ROOT}/usr \
				  --host=${FR_HOST_DEFN}-uclibc \
				  --target=${FR_HOST_DEFN}-uclibc \
				  --enable-locale=uclibc \
				  --with-sysroot=/ \
				  --enable-languages=c \
				  --disable-nls \
				  --disable-libmudflap \
				  --disable-libssp \
				  --with-gnu-as \
				  --with-gnu-ld \
				  --enable-shared \
				  || exit 1
		fi
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
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
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	#(05/11/2006) Fix 'configure.in' so we don't get problems
	# with missing directories leading to bad installs
	[ -r gcc-${PKGVER}/configure.in.OLD ] || mv gcc-${PKGVER}/configure.in gcc-${PKGVER}/configure.in.OLD || exit 1
	cat gcc-${PKGVER}/configure.in.OLD \
		| sed '/ tar .* tar / s/; tar/ \&\& tar/g' \
		> gcc-${PKGVER}/configure.in || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	# (02/09/2006) PATH requires binutils
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make || exit 1

# INSTALL...
	make install prefix=${INSTTEMP}/usr || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	PHASE=th do_configure

# BUILD...
	# (26/03/2005) ensure cmp,diff,tail PATHed
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make || exit 1

# INSTALL...
	make install-gcc || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
