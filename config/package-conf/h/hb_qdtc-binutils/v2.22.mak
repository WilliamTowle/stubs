#!/usr/bin/make
# hb_qdtc-binutils v2.22	STUBS (c) and GPLv2 1999-2015
# last modified			2015-02-05

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_BINUTILS_SRCROOT	= ${BUILDROOT}/CTI-${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_BINUTILS_CONFIGURED= ${CTI_BINUTILS_SRCROOT}/Makefile
CTI_BINUTILS_BUILT=	${CTI_BINUTILS_SRCROOT}/gas/as-new
CTI_BINUTILS_INSTALLED=	${TCTREE}/usr/bin/${TARGSPEC}-as


## ,-----
## |	Configure
## +-----

${CTI_BINUTILS_CONFIGURED}:
	( cd source/binutils-${PKGVER} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr/ \
			--host=${HOSTSPEC} --build=${HOSTSPEC} \
			--target=${TARGSPEC} \
			--disable-nls --disable-werror \
			--with-sysroot=${TCTREE}/usr/${TARGSPEC} \
			--enable-shared \
			--disable-multilib \
	)


## ,-----
## |	Build
## +-----

${CTI_BINUTILS_BUILT}: ${CTI_BINUTILS_CONFIGURED}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make \
	)


## ,-----
## |	Install
## +-----

# Ensure we have appropriate symlinks for the kernel compiler later
# [2015-02-05] Kernels after 3.10 have a new dependency on 'objdump'

${CTI_BINUTILS_INSTALLED}: ${CTI_BINUTILS_BUILT}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make install ;\
		( cd ${TCTREE}/usr/bin ;\
			for F in ar as ld nm objcopy objdump strip ; do [ -r ${TARGSPEC}-$${F} ] && ln -sf ${TARGSPEC}-$${F} ${TARGSPEC}-k$${F} ; done ;\
		) \
	)

.PHONY: cti-binutils
cti-binutils: ${CTI_BINUTILS_INSTALLED}

.PHONY: CTI
CTI: ${CTI_BINUTILS_INSTALLED}
