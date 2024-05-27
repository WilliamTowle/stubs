#!/usr/bin/make
# hb_qdul-binutils v2.22	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-09

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_BINUTILS_SRCROOT	= ${BUILDROOT}/CUI-${PKGNAME}-${PKGVER}/source/binutils-${PKGVER}

CUI_BINUTILS_CONFIGURED= ${CUI_BINUTILS_SRCROOT}/Makefile
CUI_BINUTILS_BUILT=	${CUI_BINUTILS_SRCROOT}/gas/as-new
CUI_BINUTILS_INSTALLED=	${INSTTEMP}/usr/bin/${TARGSPEC}-as


NTI_BINUTILS_SRCROOT	= ${BUILDROOT}/NTI-${PKGNAME}-${PKGVER}/source/binutils-${PKGVER}

NTI_BINUTILS_CONFIGURED= ${NTI_BINUTILS_SRCROOT}/Makefile
NTI_BINUTILS_BUILT=	${NTI_BINUTILS_SRCROOT}/gas/as-new
NTI_BINUTILS_INSTALLED=	${TCTREE}/usr/bin/${HOSTSPEC}-as


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

${NTI_BINUTILS_CONFIGURED}:
	( cd source/binutils-${PKGVER} || exit 1 ;\
		CC=/usr/bin/gcc \
                  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${TCTREE}/usr \
			  --host=${HOSTSPEC} \
			  --build=${HOSTSPEC} \
			  --target=${HOSTSPEC} \
                          --program-prefix=${HOSTSPEC}- \
                          --with-sysroot=/ \
                          --with-lib-path=/lib:/usr/lib \
                          --enable-shared \
                          --disable-largefile --disable-nls \
	)


## ,-----
## |	Build
## +-----

${CUI_BINUTILS_BUILT}: ${CUI_BINUTILS_CONFIGURED}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make \
	)

${NTI_BINUTILS_BUILT}: ${NTI_BINUTILS_CONFIGURED}
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

##

${NTI_BINUTILS_INSTALLED}: ${NTI_BINUTILS_BUILT}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make install \
	)

.PHONY: nti-binutils
nti-binutils: ${NTI_BINUTILS_INSTALLED}

.PHONY: NTI
NTI: nti-binutils
