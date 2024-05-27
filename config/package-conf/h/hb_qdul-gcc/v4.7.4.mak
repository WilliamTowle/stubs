#!/usr/bin/make
# hb_qdul-gcc v4.8.5	   	STUBS (c) and GPLv2 1999-2017
# last modified			2017-01-30

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
# [2017-01-10] MAKEINFO=/bin/false skips build-docs phase for speed

${CUI_GCC_CONFIGURED}:
	mkdir source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
		mv ../../mpc-1.0.1 ../mpc || exit 1 ;\
                CC=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  CC_FOR_BUILD=/usr/bin/gcc \
                  AS_FOR_BUILD=/usr/bin/as \
                  LD_FOR_BUILD=/usr/bin/ld \
                  AR_FOR_BUILD=/usr/bin/ar \
                  NM_FOR_BUILD=/usr/bin/nm \
                  HOSTCC=/usr/bin/gcc \
                  GCC_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  AR=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  AS=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  LD=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  NM=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  RANLIB=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
		  MAKEINFO=/bin/false CFLAGS='-O2' \
		../configure --prefix=/usr/ \
			--build=${HOSTSPEC} --host=${TARGSPEC} \
			--target=${TARGSPEC} \
			--enable-clocale=uclibc \
			--enable-languages=c \
		 	--disable-__cxa_atexit \
			--with-sysroot=/ \
			--disable-nls --disable-werror \
			--disable-mudflap \
			--disable-libssp \
			--disable-decimal-float \
			--enable-threads --disable-libgomp \
			--enable-shared \
			--with-gnu-as \
			--with-gnu-ld \
	)

${NTI_GCC_CONFIGURED}:
	mkdir source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		mv ../../gmp-4.3.2 ../gmp || exit 1 ;\
		mv ../../mpfr-2.4.2 ../mpfr || exit 1 ;\
		mv ../../mpc-1.0.1 ../mpc || exit 1 ;\
                CC=/usr/bin/gcc \
		  MAKEINFO=/bin/false CFLAGS='-O2' \
			../configure -v \
			  --prefix=${TCTREE}'/usr/' \
			  --host=${HOSTSPEC} --build=${HOSTSPEC} \
			  --target=${HOSTSPEC} \
                          --with-sysroot=/ \
                          --with-local-prefix=${TCTREE}'/usr/' \
                          --enable-languages=c \
                          --disable-nls --disable-werror \
                          --disable-libmudflap \
                          --disable-libssp \
                          --enable-shared \
	)


## ,-----
## |	Build
## +-----

${CUI_GCC_BUILT}: ${CUI_GCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make all \
	)

${NTI_GCC_BUILT}: ${NTI_GCC_CONFIGURED}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make all \
	)


## ,-----
## |	Install
## +-----

${CUI_GCC_INSTALLED}: ${CUI_GCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)

.PHONY: cui-gcc
cui-gcc: ${CUI_GCC_INSTALLED}

.PHONY: CUI
CUI: ${CUI_GCC_INSTALLED}


${NTI_GCC_INSTALLED}: ${NTI_GCC_BUILT}
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
		make install-gcc \
	)

.PHONY: nti-gcc
nti-gcc: ${NTI_GCC_INSTALLED}

.PHONY: NTI
NTI: ${NTI_GCC_INSTALLED}
