#!/usr/bin/make
# hb_qdul-gcc v4.1.2	   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-20

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_GCC_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_GCC_CONFIGURED	= ${CUI_GCC_SRCROOT}/libiberty/Makefile
CUI_GCC_BUILT		= ${CUI_GCC_SRCROOT}/gcc
CUI_GCC_INSTALLED	= ${INSTTEMP}/usr/bin/gcc


## ,-----
## |	Configure
## +-----

## NB. Use of the gcc "core" archive means some patches will fail,
## and the mechanism leaves these behind. Any that apply to the "core"
## sources but which aren't written for use with '-Np1' will also fail.

${CUI_GCC_CONFIGURED}:
	mkdir source/gcc-${PKGVER}/build
	( cd source/gcc-${PKGVER} || exit 1 ;\
		for PF in ../patch/*patch ../uclibc/*patch ; do \
			echo "PATCHING: PF $${PF}" ;\
			patch -Np1 -i $${PF} && rm -f $${PF} ;\
		done ; true \
	)
	( cd source/gcc-${PKGVER}/build || exit 1 ;\
                CC=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  CC_FOR_BUILD=/usr/bin/gcc \
                  HOSTCC=/usr/bin/gcc \
                  GCC_FOR_TARGET=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  AR=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  AS=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  LD=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  NM=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  RANLIB=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
                  CFLAGS=-O2 \
		../configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} --target=${TARGSPEC} \
			--enable-clocale=uclibc \
			--enable-languages=c \
		 	--disable-__cxa_atexit \
			--with-sysroot=/ \
			--disable-mudflap \
			--disable-libssp \
			--enable-shared \
			--with-gnu-as \
			--with-gnu-ld \
			--disable-nls \
	)
#			--program-prefix=''


## ,-----
## |	Build
## +-----

${CUI_GCC_BUILT}: ${CUI_GCC_CONFIGURED}
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
