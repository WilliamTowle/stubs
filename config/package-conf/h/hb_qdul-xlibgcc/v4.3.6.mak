#!/usr/bin/make
# hb_qdul-xlibgcc v4.4.7	STUBS (c) and GPLv2 1999-2013
# last modified			2013-05-09

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

${CUI_XLIBGCC_CONFIGURED}:
	mkdir -p source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
                CC=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  AR=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  AS=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  LD=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  NM=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  RANLIB=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
                  CFLAGS='-O2' \
		../configure --prefix=/usr/ \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} --target=${TARGSPEC} \
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

# Ensure we have appropriate symlinks for the kernel compiler later
${CUI_XLIBGCC_INSTALLED}: ${CUI_XLIBGCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make install-target-libgcc DESTDIR=${INSTTEMP} \
	)

.PHONY: cui-xlibgcc
cui-xlibgcc: ${CUI_XLIBGCC_INSTALLED}

.PHONY: CUI
CUI: ${CUI_XLIBGCC_INSTALLED}
