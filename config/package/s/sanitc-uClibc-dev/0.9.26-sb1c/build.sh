#!/bin/sh -x
# 2007-08-04 (prev. 2007-02-25)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PHASE} in
	th)
		(
		case ${PKGVER} in
		0.9.20)
			echo 'KERNEL_SOURCE="'${FR_KERNSRC}'"'
			echo 'SHARED_LIB_LOADER_PATH="/lib"'
		;;
		0.9.26)
			echo 'KERNEL_SOURCE="'${FR_KERNSRC}'"'
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"'
			echo 'RUNTIME_PREFIX="/"'
			echo 'UCLIBC_HAS_SYS_SIGLIST=y'
		;;
		0.9.28*)
			echo 'KERNEL_SOURCE="'${FR_KERNSRC}'"'
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"'
			echo 'RUNTIME_PREFIX="/"'
			echo 'CROSS_COMPILER_PREFIX="'${FR_TC_ROOT}'/usr/bin/'`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`'-"'
			echo 'UCLIBC_HAS_SYS_SIGLIST=y'
			echo '# UCLIBC_HAS_SHADOW is not set'
		;;
		*)
			echo "$0: do_configure: Unexpected PKGVER ${PKGVER}" 1>&2
			exit 1
		;;
		esac
		echo 'DEVEL_PREFIX="'${FR_TC_ROOT}'/usr/'${FR_TARGET_DEFN}'/usr/"'
		case "${TARGET_CPU}" in
		i386)
		      echo 'TARGET_ARCH="'${TARGET_CPU}'"'
		      echo 'TARGET_'${TARGET_CPU}'=y'
		;;
		mips*)
		      echo 'TARGET_ARCH="mips"'
		      echo 'TARGET_mips=y'
		      [ ${TARGET_CPU} = 'mips' ] && echo 'ARCH_SUPPORTS_BIG_ENDIAN=y'
		      [ ${TARGET_CPU} = 'mips' ] && echo 'ARCH_BIG_ENDIAN=y'
		      [ ${TARGET_CPU} = 'mipsel' ] && echo 'ARCH_LITTLE_ENDIAN=y'
		      echo 'CONFIG_MIPS_ISA_MIPS32=y'
		;;
		*)
		      echo "Unexpected TARGET_CPU '${TARGET_CPU}'" 1>&2
		      exit 1
		;;
		esac
		echo '# ASSUME_DEVPTS is not set'
		echo 'MALLOC=y'
		echo '# MALLOC_930716 is not set'
		echo 'MALLOC_STANDARD=y'
		echo 'DO_C99_MATH=y'
		[ -r /lib/ld-linux.so.1 ] && echo '# DOPIC is not set'
		[ -r /lib/ld-linux.so.1 ] && echo '# HAVE_SHARED is not set'
		echo '# UCLIBC_HAS_IPV6 is not set'
		echo '# UCLIBC_HAS_LFS is not set'
		echo 'UCLIBC_HAS_RPC=y'
		echo 'UCLIBC_HAS_FULL_RPC=y'
		echo '# UCLIBC_HAS_CTYPE_UNSAFE is not set'
		echo 'UCLIBC_HAS_CTYPE_CHECKED=y'
		echo '# UNIX98PTY_ONLY is not set'
		) > .config || exit 1
	;;
	dc)
		cp ${TCTREE}/etc/${USE_TOOLCHAIN}/uClibc-${PKGVER}-config .config || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac

	case ${PKGVER} in
	0.9.26)
		[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1
		cat Rules.mak.OLD \
			| sed	' /^CROSS/	s%=.*%= '${FR_TC_ROOT}'/usr/bin/'`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-[^-]*/-kernel-linux/'`'-% ; /(CROSS)/	s%$(CROSS)%$(shell if [ -n "${CROSS}" ] ; then echo ${CROSS} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$//'`'" ; fi)% ; /USE_CACHE/ s/#//' \
			> Rules.mak || exit 1
	;;
	esac

	yes '' | make HOSTCC=${FR_HOST_CC} oldconfig \
		  || exit 1

	if [ ${PHASE} = 'th' ] ; then
		mkdir -p ${TCTREE}/etc/${USE_TOOLCHAIN}
		cp .config ${TCTREE}/etc/${USE_TOOLCHAIN}/uClibc-${PKGVER}-config || exit 1
	fi
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

	PHASE=dc do_configure || exit 1

# BUILD...
	make || exit 1
#	make CROSS=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}- \
#		HOSTCC=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc \
#		-C ldso/util --always-make ldd \
#		|| exit 1

## INSTALL...
	case ${PKGVER} in
	0.9.20)
 		make PREFIX=${INSTTEMP}/ DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_dev || exit 1
		cp ldso/util/ldd ${INSTTEMP}/usr/bin || exit 1
	;;
	0.9.22|0.9.24|0.9.26)
 		make PREFIX=${INSTTEMP}/ DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_dev || exit 1
	;;
	*)	echo "$0: Install: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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

	PHASE=th do_configure || exit 1

# BUILD...
	make || exit 1 

# INSTALL...
	make install_dev || exit 1
	make RUNTIME_PREFIX=${FR_TC_ROOT}'/usr/'${FR_TARGET_DEFN}'/usr/' install_runtime || exit 1
	( cd ${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}/usr/lib || exit 1
		for F in *.so ; do [ -L ${F} ] && ln -sf ${F}.0 ${F} ; done
		true
	) || exit 1
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
