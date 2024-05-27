#!/usr/bin/make
# xz v5.0.5		   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-08-08

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_XZ_SRCROOT	= ${BUILDROOT}/NTI-xz-${PKGVER}/source/${PKGNAME}-${PKGVER}
CUI_XZ_SRCROOT	= ${BUILDROOT}/CUI-xz-${PKGVER}/source/${PKGNAME}-${PKGVER}

NTI_XZ_CONFIGURED=	${NTI_XZ_SRCROOT}/config.log
NTI_XZ_BUILT=		${NTI_XZ_SRCROOT}/src/xz
NTI_XZ_INSTALLED=	${TCTREE}/usr/bin/xz

CUI_XZ_CONFIGURED=	${CUI_XZ_SRCROOT}/config.log
CUI_XZ_BUILT=		${CUI_XZ_SRCROOT}/src/xz
CUI_XZ_INSTALLED=	${INSTTEMP}/usr/bin/xz


## ,-----
## |	Configure
## +-----

${NTI_XZ_CONFIGURED}:
	( cd ${NTI_XZ_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_XZ_CONFIGURED}:
	( cd ${CUI_XZ_SRCROOT} || exit 1 ;\
		./configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} \
			--disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${NTI_XZ_BUILT}: ${NTI_XZ_CONFIGURED}
	( cd ${NTI_XZ_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_XZ_BUILT}: ${CUI_XZ_CONFIGURED}
	( cd ${CUI_XZ_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_XZ_INSTALLED}: ${NTI_XZ_BUILT}
	( cd ${NTI_XZ_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-xz
nti-xz: ${NTI_XZ_INSTALLED}

.PHONY: NTI
NTI: ${NTI_XZ_INSTALLED}


${CUI_XZ_INSTALLED}: ${CUI_XZ_BUILT}
	( cd ${CUI_XZ_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-xz
cui-xz: ${CUI_XZ_INSTALLED}

.PHONY: CUI
CUI: ${CUI_XZ_INSTALLED}
