#!/bin/sh -x
# 31/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
#??! if [ "${PHASE}" == 'tc' ] ; then
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
#fi

	case ${PHASE} in
	dc)
		CC=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc \
		  CC_FOR_BUILD=${FR_HOST_CC} \
		  HOSTCC=${FR_HOST_CC} \
	  	  AR=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-ar \
	  	  AS=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-as \
	  	  LD=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-ld \
	  	  NM=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-nm \
	  	  RANLIB=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-ranlib \
	    	  CFLAGS=-O2 \
			./binutils-${PKGVER}/configure \
			  --prefix=/usr \
			  --host=`echo ${FR_HOST_DEFN} | sed 's/-gnulibc1$/-gnu/'` \
			  --build=${FR_TARGET_DEFN} \
			  --target=${FR_TARGET_DEFN} \
			  --program-prefix="''" \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1
#			  --disable-werror \
#			  --program-transform-name='s,'${FR_TARGET_DEFN}',,'
	;;
	th)
		HAVE_GLIBC_SYSTEM=`if [ -r /lib/libc.so.6 ] ; then echo y ; else echo n ; fi`

		if [ ${HAVE_GLIBC_SYSTEM} = 'y' ] ; then
			# (26/03/2005) PATH needs cmp,diff,flex
			PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			  CC=${FR_HOST_CC} \
			  CFLAGS=-O2 \
				./binutils-${PKGVER}/configure -v \
				  --prefix=${FR_TH_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --target=${FR_HOST_DEFN} \
				  --program-prefix="''" \
				  --with-sysroot=/ \
				  --with-lib-path=/lib:/usr/lib \
				  --enable-shared \
				  --disable-largefile --disable-nls \
				  || exit 1
#			  --disable-werror \
#			  --program-transform-name='s,'${TARGET_SPEC}'-,,'
		else
			# provided 'install' script assumes we have bash :(
			FR_INSTALL=`PATH=${FR_TH_ROOT}/bin:${PATH} which install`
			if [ -z "${FR_INSTALL}" ] ; then
				echo "$0: Confused - No 'install'" 1>&2
				exit 1
			fi
	
			# (26/03/2005) PATH needs cmp,diff,flex
			PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			  CC=${FR_HOST_CC} \
			  ac_cv_sizeof_long_long=8 \
			  ac_cv_path_install=${FR_INSTALL} \
			  CFLAGS=-O2 \
				./binutils-${PKGVER}/configure -v \
				  --prefix=${FR_TH_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --target=${FR_HOST_DEFN} \
				  --program-prefix=${FR_HOST_DEFN}- \
				  --with-sysroot=/ \
				  --with-lib-path=/lib:/usr/lib \
				  --enable-shared \
				  --disable-largefile --disable-nls \
				  || exit 1
#				  --disable-werror \
#			  --program-transform-name='s,'${TARGET_SPEC}'-,,'
		fi
	;;
	*)
		echo "$0: do_configure(): Unexpected PHASE ${PHASE}" 1>&2
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

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
	# (26/03/2005) PATH needs (f)lex
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  make || exit 1

# INSTALL...
	make install DESTDIR=${INSTTEMP} || exit 1
}

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

	PHASE=th do_configure

# BUILD...
	# (26/03/2005) PATH needs (f)lex
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  make || exit 1

# INSTALL...
	# (16/09/2006) `make install` needs appropriate ranlib
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make install || exit 1
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
