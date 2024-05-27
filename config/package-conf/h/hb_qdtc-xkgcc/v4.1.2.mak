#!/usr/bin/make
# hb_qdtc-kgcc v4.1.2	   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-07-18

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_KGCC_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_KGCC_CONFIGURED	= ${CTI_KGCC_SRCROOT}/libiberty/Makefile
CTI_KGCC_BUILT		= ${CTI_KGCC_SRCROOT}/gcc
CTI_KGCC_INSTALLED	= ${TCTREE}/usr/bin/${TARGSPEC}-kgcc


## ,-----
## |	Configure
## +-----

${CTI_KGCC_CONFIGURED}:
	( cd source/gcc-${PKGVER} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr/ \
			--host=${HOSTSPEC} --build=${HOSTSPEC} \
			--target=${TARGSPEC} \
			--program-transform-name='s%^%'${TARGSPEC}'-k%' \
			--disable-nls --disable-werror \
			--with-sysroot=${TCTREE}/usr/${TARGSPEC} \
			--without-headers \
			--with-newlib \
			--enable-languages=c \
			--disable-__cxa_atexit \
			--disable-mutilib \
			--disable-decimal-float \
			--disable-mudflap \
			--disable-ssp \
			--disable-shared \
			--disable-threads \
			--disable-libgomp \
	)


## ,-----
## |	Build
## +-----

# [2012-06-09] may want uClibc without "Target CPU has an FPU" - depends on some libgcc parts
${CTI_KGCC_BUILT}: ${CTI_KGCC_CONFIGURED}
	( cd source/gcc-${PKGVER} || exit 1 ;\
		make all-gcc \
	)


## ,-----
## |	Install
## +-----

# Ensure we have appropriate symlinks for the kernel compiler later
${CTI_KGCC_INSTALLED}: ${CTI_KGCC_BUILT}
	( cd source/gcc-${PKGVER} || exit 1 ;\
		make install-gcc \
	)

.PHONY: cti-kgcc
cti-kgcc: ${CTI_KGCC_INSTALLED}

.PHONY: CTI
CTI: ${CTI_KGCC_INSTALLED}
