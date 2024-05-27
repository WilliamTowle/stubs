#!/usr/bin/make
# hb_qdul-xlibgcc v4.8.5	STUBS (c) and GPLv2 1999-2017
# last modified			2017-01-30

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_XLIBGCC_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_XLIBGCC_CONFIGURED	= ${CUI_XLIBGCC_SRCROOT}/libiberty/Makefile
CUI_XLIBGCC_BUILT	= ${CUI_XLIBGCC_SRCROOT}/gcc-libgcc.a
CUI_XLIBGCC_INSTALLED	= ${TCTREE}/usr/lib/gcc/${TARGSPEC}/${PKGVER}/libgcc.a


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

## [2013-05-09] userland needs libgcc_s.so; try without --disable-shared
## ...working but installs more files than necessary ('startfiles'??)

# [2017-01-10] MAKEINFO=/bin/false skips build-docs phase for speed
# [2017-01-30] '*-target-libgcc' rules don't need --sysroot=
# [2017-02-01] Can fail to size arrays in gcc/real.h (64-bit host?)

${CUI_XLIBGCC_CONFIGURED}:
	mkdir -p source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
		mv ../../mpc-1.0.1 ../mpc || exit 1 ;\
                ____CC=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  CC_FOR_BUILD=/usr/bin/gcc \
                  AS_FOR_BUILD=/usr/bin/as \
                  LD_FOR_BUILD=/usr/bin/ld \
                  AR_FOR_BUILD=/usr/bin/ar \
                  NM_FOR_BUILD=/usr/bin/nm \
                  __HOSTCC=/usr/bin/gcc \
                  __GCC_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  ____AR=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  __AR_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  ____AS=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  __AS_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  ____LD=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  __LD_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  ____NM=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  __NM_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  ____RANLIB=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
                  __RANLIB_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
		  MAKEINFO=/bin/false CFLAGS='-O2' \
		../configure --prefix='/usr/' \
			--build=${HOSTSPEC} --host=${TARGSPEC} \
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
			--disable-threads \
			--disable-libgomp \
	)


## ,-----
## |	Build
## +-----

# [2012-06-09] may want uClibc without "Target CPU has an FPU" - depends on some libgcc parts

${CUI_XLIBGCC_BUILT}: ${CUI_XLIBGCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make all-target-libgcc \
	)


## ,-----
## |	Install
## +-----

${CUI_XLIBGCC_INSTALLED}: ${CUI_XLIBGCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make install-target-libgcc DESTDIR=${INSTTEMP} \
	)

.PHONY: cui-xlibgcc
cui-xlibgcc: ${CUI_XLIBGCC_INSTALLED}

.PHONY: CUI
CUI: ${CUI_XLIBGCC_INSTALLED}
