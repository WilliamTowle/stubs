#!/usr/bin/make
# patch v2.5.9		   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-12-22

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_PATCH_SRCROOT	= ${BUILDROOT}/NTI-patch-${PKGVER}/source/${PKGNAME}-${PKGVER}
CUI_PATCH_SRCROOT	= ${BUILDROOT}/CUI-patch-${PKGVER}/source/${PKGNAME}-${PKGVER}

NTI_PATCH_CONFIGURED=	${NTI_PATCH_SRCROOT}/config.status
NTI_PATCH_BUILT=	${NTI_PATCH_SRCROOT}/patch
NTI_PATCH_INSTALLED=	${TCTREE}/usr/bin/patch

CUI_PATCH_CONFIGURED=	${CUI_PATCH_SRCROOT}/config.status
CUI_PATCH_BUILT=	${CUI_PATCH_SRCROOT}/patch
CUI_PATCH_INSTALLED=	${INSTTEMP}/usr/bin/patch


## ,-----
## |	Configure
## +-----

${NTI_PATCH_CONFIGURED}:
	( cd ${NTI_PATCH_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_PATCH_CONFIGURED}:
	( cd ${CUI_PATCH_SRCROOT} || exit 1 ;\
		./configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} \
			--disable-largefile --disable-nls ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed 's%$${prefix}%$${DESTDIR}/$${prefix}%' \
			> Makefile || exit 1 \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${NTI_PATCH_BUILT}: ${NTI_PATCH_CONFIGURED}
	( cd ${NTI_PATCH_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_PATCH_BUILT}: ${CUI_PATCH_CONFIGURED}
	( cd ${CUI_PATCH_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_PATCH_INSTALLED}: ${NTI_PATCH_BUILT}
	( cd ${NTI_PATCH_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-patch
nti-patch: ${NTI_PATCH_INSTALLED}

.PHONY: NTI
NTI: ${NTI_PATCH_INSTALLED}


${CUI_PATCH_INSTALLED}: ${CUI_PATCH_BUILT}
	( cd ${CUI_PATCH_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-patch
cui-patch: ${CUI_PATCH_INSTALLED}

.PHONY: CUI
CUI: ${CUI_PATCH_INSTALLED}
