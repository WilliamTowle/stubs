#!/usr/bin/make
# hb_qdtc-xlibgcc v4.8.5	STUBS (c) and GPLv2 1999-2017
# last modified			2017-01-30

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_XLIBGCC_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_XLIBGCC_CONFIGURED	= ${CTI_XLIBGCC_SRCROOT}/libiberty/Makefile
CTI_XLIBGCC_BUILT	= ${CTI_XLIBGCC_SRCROOT}/gcc-libgcc.a
CTI_XLIBGCC_INSTALLED	= ${TCTREE}/usr/lib/gcc/${TARGSPEC}/${PKGVER}/libgcc.a


## ,-----
## |	Configure
## +-----

# [gcc 4.3.6] building in own source directory fixes "libgcc.mvars" problem
#
# Don't need anything complicated (mudflap, ssp, threads...)
# --disable-shared cuts down what we build for libgcc
#
# uClibc vs libgcc config:
# * --disable-decimal-float stops 'fenv.h' being a requirement [uClibc vs libgcc config]
# * --disable-threads stops 'pthread.h' being a requirement
# * libgomp incompatible with --disable-threads

# [2017-01-10] MAKEINFO=/bin/false skips build-docs phase for speed
# [2017-01-30] '*-target-libgcc' rules don't need --sysroot=

${CTI_XLIBGCC_CONFIGURED}:
	mkdir -p source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
		mv ../../mpc-1.0.1 ../mpc || exit 1 ;\
		  MAKEINFO=/bin/false CFLAGS='-O2' \
		../configure --prefix=${TCTREE}'/usr/' \
			--build=${HOSTSPEC} --host=${HOSTSPEC} \
			--target=${TARGSPEC} \
			--program-transform-name='s%^%'${TARGSPEC}'-k%' \
			--disable-nls --disable-werror \
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
${CTI_XLIBGCC_BUILT}: ${CTI_XLIBGCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make all-target-libgcc \
	)


## ,-----
## |	Install
## +-----

# Ensure we have appropriate symlinks for the kernel compiler later
${CTI_XLIBGCC_INSTALLED}: ${CTI_XLIBGCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make install-target-libgcc \
	)

.PHONY: cti-xlibgcc
cti-xlibgcc: ${CTI_XLIBGCC_INSTALLED}

.PHONY: CTI
CTI: ${CTI_XLIBGCC_INSTALLED}
