#!/usr/bin/make
# hb_qdul-binutils v2.17	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-27

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_BINUTILS_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_BINUTILS_CONFIGURED= ${CUI_BINUTILS_SRCROOT}/Makefile
CUI_BINUTILS_BUILT=	${CUI_BINUTILS_SRCROOT}/gas/as-new
CUI_BINUTILS_INSTALLED=	${INSTTEMP}/usr/bin/${TARGSPEC}-as


## ,-----
## |	Configure
## +-----

${CUI_BINUTILS_CONFIGURED}:
	( cd source/binutils-${PKGVER} || exit 1 ;\
		CC=${TCTREE}/usr/bin/${TARGSPEC}-gcc \
                  CC_FOR_BUILD=/usr/bin/gcc \
                  HOSTCC=/usr/bin/gcc \
                  AR=${TCTREE}/usr/bin/${TARGSPEC}-ar \
                  AS=${TCTREE}/usr/bin/${TARGSPEC}-as \
                  LD=${TCTREE}/usr/bin/${TARGSPEC}-ld \
                  NM=${TCTREE}/usr/bin/${TARGSPEC}-nm \
                  RANLIB=${TCTREE}/usr/bin/${TARGSPEC}-ranlib \
                  CFLAGS=-O2 \
		./configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} --target=${TARGSPEC} \
			--program-prefix='' \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  --disable-werror \
	)


## ,-----
## |	Build
## +-----

${CUI_BINUTILS_BUILT}: ${CUI_BINUTILS_CONFIGURED}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make \
	)


## ,-----
## |	Install
## +-----

${CUI_BINUTILS_INSTALLED}: ${CUI_BINUTILS_BUILT}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)

.PHONY: cui-binutils
cui-binutils: ${CUI_BINUTILS_INSTALLED}

.PHONY: CUI
CUI: cui-binutils
