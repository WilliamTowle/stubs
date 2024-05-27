#!/usr/bin/make
# hb_qdtc-ucldev v0.9.28.3   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-28

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_UCLDEV_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_UCLDEV_CONFIGURED	= ${CTI_UCLDEV_SRCROOT}/.config
CTI_UCLDEV_BUILT	= ${CTI_UCLDEV_SRCROOT}/lib/ld-uClibc-0.9.28.3.so
CTI_UCLDEV_INSTALLED	= ${TCTREE}/etc/config-uClibc-${PKGVER}


## ,-----
## |	Configure
## +-----

${CTI_UCLDEV_CONFIGURED}:
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		( \
		echo 'DEVEL_PREFIX="/usr/"' ;\
		      echo 'TARGET_ARCH="'${TARGCPU}'"' ;\
		      echo 'TARGET_'${TARGCPU}'=y' ;\
			echo 'KERNEL_SOURCE="'${TCTREE}'/usr/'${TARGSPEC}'/usr/src/linux/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'CROSS_COMPILER_PREFIX="'${TCTREE}'/usr/bin/'${TARGSPEC}'-k"' ;\
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' ;\
			echo '# UCLIBC_HAS_SHADOW is not set' ;\
			echo 'MALLOC=y' ;\
			echo 'MALLOC_STANDARD=y' ;\
		echo '# ASSUME_DEVPTS is not set' ;\
		echo 'DO_C99_MATH=y' ;\
		[ -r /lib/ld-linux.so.1 ] && echo '# DOPIC is not set' ;\
		[ -r /lib/ld-linux.so.1 ] && echo '# HAVE_SHARED is not set' ;\
		echo '# UCLIBC_HAS_IPV6 is not set' ;\
		echo '# UCLIBC_HAS_LFS is not set' ;\
		echo 'UCLIBC_HAS_RPC=y' ;\
		echo 'UCLIBC_HAS_FULL_RPC=y' ;\
		echo '# UCLIBC_HAS_CTYPE_UNSAFE is not set' ;\
		echo 'UCLIBC_HAS_CTYPE_CHECKED=y' ;\
		echo '# UNIX98PTY_ONLY is not set' \
	 	) > .config ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig \
	)


## ,-----
## |	Build
## +-----

# 0.9.28.3 has a specific rule for ldd.host
# 'headers' and 'startfiles' not separated out in versions this early

${CTI_UCLDEV_BUILT}: ${CTI_UCLDEV_CONFIGURED}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		${MAKE} || exit 1 ;\
		${MAKE} -C utils ldd.host \
	)


## ,-----
## |	Install
## +-----

${CTI_UCLDEV_INSTALLED}: ${CTI_UCLDEV_BUILT}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		${MAKE} PREFIX=${TCTREE}'/usr/'${TARGSPEC}'/' install_dev || exit 1 ;\
		cp utils/ldd.host ${TCTREE}/usr/bin/${TARGSPEC}-ldd || exit 1 ;\
		mkdir -p ${TCTREE}/etc/ ;\
		cp .config ${CTI_UCLDEV_INSTALLED} \
	)
#		${MAKE} RUNTIME_PREFIX=${TCTREE}'/usr/'${TARGSPEC}'/usr/' install_runtime || exit 1 ;\
#		( cd ${TCTREE}/usr/${TARGSPEC}/usr/lib || exit 1 ;\
#			for F in *.so ; do [ -L $${F} ] && ln -sf $${F}.0 $${F} ; done \
#		) || exit 1 ;\

.PHONY: cti-ucldev
cti-ucldev: ${CTI_UCLDEV_INSTALLED}

.PHONY: CTI
CTI: ${CTI_UCLDEV_INSTALLED}
