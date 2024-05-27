#!/usr/bin/make
# hb_qdtc-xgcc v4.4.7	   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-20

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_GCC_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_GCC_CONFIGURED	= ${CTI_GCC_SRCROOT}/libiberty/Makefile
CTI_GCC_BUILT		= ${CTI_GCC_SRCROOT}/gcc
CTI_GCC_INSTALLED	= ${TCTREE}/usr/bin/${TARGSPEC}-gcc


## ,-----
## |	Configure
## +-----

# possibly --disable-shared?
# --disable-decimal-float stops 'fenv.h' being a requirement [uClibc config?]
# --disable-threads stops 'pthread.h' being a requirement [uClibc config]
# libgomp incompatable with --disable-threads
# mudflap implied somehow (target iFOO-uClibc?); better disabled
${CTI_GCC_CONFIGURED}:
	mkdir source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
		../configure --prefix=${TCTREE}/usr/ \
			--host=${HOSTSPEC} --build=${HOSTSPEC} \
			--target=${TARGSPEC} \
			--with-sysroot=${TCTREE}/usr/${TARGSPEC} \
			--disable-nls \
			--disable-multilib \
			--disable-shared \
			--enable-languages=c \
			--enable-clocale=uclibc \
		 	--disable-__cxa_atexit \
			--disable-decimal-float \
			--disable-threads \
			--disable-libgomp \
			--disable-mudflap \
	)


## ,-----
## |	Build
## +-----

${CTI_GCC_BUILT}: ${CTI_GCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make all \
	)


## ,-----
## |	Install
## +-----

# Ensure we have appropriate symlinks for the kernel compiler later
${CTI_GCC_INSTALLED}: ${CTI_GCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make install ;\
		( cd ${TCTREE}/usr/bin && ln -sf ${TARGSPEC}-gcc-${PKGVER} ${TARGSPEC}-gcc ) \
	)

.PHONY: cti-gcc
cti-gcc: ${CTI_GCC_INSTALLED}

.PHONY: CTI
CTI: ${CTI_GCC_INSTALLED}
