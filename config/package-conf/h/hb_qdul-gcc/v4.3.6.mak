#!/usr/bin/make
# hb_qdul-gcc v4.3.6	   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-09

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_GCC_SRCROOT	= ${BUILDROOT}/CUI-${PKGNAME}-${PKGVER}/source/gcc-${PKGVER}

CUI_GCC_CONFIGURED	= ${CUI_GCC_SRCROOT}/libiberty/Makefile
CUI_GCC_BUILT		= ${CUI_GCC_SRCROOT}/gcc
CUI_GCC_INSTALLED	= ${INSTTEMP}/usr/bin/gcc


NTI_GCC_SRCROOT	= ${BUILDROOT}/NTI-${PKGNAME}-${PKGVER}/source/gcc-${PKGVER}

NTI_GCC_CONFIGURED	= ${NTI_GCC_SRCROOT}/libiberty/Makefile
NTI_GCC_BUILT		= ${NTI_GCC_SRCROOT}/gcc
NTI_GCC_INSTALLED	= ${TCTREE}/usr/bin/${HOSTSPEC}-gcc


## ,-----
## |	Configure
## +-----

# [2012-08-24] adapt host-linux.c to get SSIZE_MAX definition from posix1_lim.h
# mudflap implied somehow (target iFOO-uClibc?); better disabled
# --disable-decimal-float stops 'fenv.h' being a requirement [uClibc config?]
# --disable-threads stops 'pthread.h' being a requirement [uClibc config]
# libgomp incompatable with --disable-threads

# [2012-09-17] want --enable-threads

${CUI_GCC_CONFIGURED}:
	mkdir source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
                CC=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  CC_FOR_BUILD=/usr/bin/gcc \
                  HOSTCC=/usr/bin/gcc \
                  GCC_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  AR=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  AS=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  LD=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  NM=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  RANLIB=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
                  CFLAGS='-O2' \
		../configure --prefix=/usr/ \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} --target=${TARGSPEC} \
			--enable-clocale=uclibc \
			--enable-languages=c \
		 	--disable-__cxa_atexit \
			--with-sysroot=/ \
			--disable-nls \
			--disable-mudflap \
			--disable-libssp \
			--disable-decimal-float \
			--enable-threads --disable-libgomp \
			--enable-shared \
			--with-gnu-as \
			--with-gnu-ld \
	)

# [2014-05-13] want --disable-multilib, as with kernel-only compiler
# [2014-05-13] C_INCLUDE_PATH necessary on multilib host?

${NTI_GCC_CONFIGURED}:
	mkdir source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
                CC=/usr/bin/gcc \
                  CFLAGS='-O2' \
		  C_INCLUDE_PATH=/usr/include/$(/usr/bin/gcc -print-multiarch) \
			../configure -v \
			  --prefix=${TCTREE}/usr/ \
			  --host=${HOSTSPEC} \
			  --build=${HOSTSPEC} \
			  --target=${HOSTSPEC} \
                          --with-sysroot=/ \
                          --with-local-prefix=${TCTREE}/usr \
                          --enable-languages=c \
                          --disable-nls \
                          --disable-libmudflap \
                          --disable-libssp \
			  --disable-multilib \
                          --enable-shared \
	)


## ,-----
## |	Build
## +-----

${CUI_GCC_BUILT}: ${CUI_GCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		${MAKE} all \
	)

${NTI_GCC_BUILT}: ${NTI_GCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		${MAKE} all-gcc \
	)


## ,-----
## |	Install
## +-----

${CUI_GCC_INSTALLED}: ${CUI_GCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		${MAKE} install DESTDIR=${INSTTEMP} \
	)

.PHONY: cui-gcc
cui-gcc: ${CUI_GCC_INSTALLED}

.PHONY: CUI
CUI: ${CUI_GCC_INSTALLED}


${NTI_GCC_INSTALLED}: ${NTI_GCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		${MAKE} install-gcc \
	)

.PHONY: nti-gcc
nti-gcc: ${NTI_GCC_INSTALLED}

.PHONY: NTI
NTI: ${NTI_GCC_INSTALLED}
