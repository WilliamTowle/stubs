#!/usr/bin/make
# m4 v1.4.16		   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-02

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_M4_SRCROOT	= ${BUILDROOT}/NTI-m4-${PKGVER}/source/${PKGNAME}-${PKGVER}
CUI_M4_SRCROOT	= ${BUILDROOT}/CUI-m4-${PKGVER}/source/${PKGNAME}-${PKGVER}

NTI_M4_CONFIGURED=	${NTI_M4_SRCROOT}/config.status
NTI_M4_BUILT=	${NTI_M4_SRCROOT}/m4
NTI_M4_INSTALLED=	${TCTREE}/usr/bin/m4

CUI_M4_CONFIGURED=	${CUI_M4_SRCROOT}/config.status
CUI_M4_BUILT=	${CUI_M4_SRCROOT}/m4
CUI_M4_INSTALLED=	${INSTTEMP}/usr/bin/m4


## ,-----
## |	Configure
## +-----

${NTI_M4_CONFIGURED}:
	( cd ${NTI_M4_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_M4_CONFIGURED}:
	( cd ${CUI_M4_SRCROOT} || exit 1 ;\
		echo '*** UNTESTED ***' ; exit 1 ;\
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

${NTI_M4_BUILT}: ${NTI_M4_CONFIGURED}
	( cd ${NTI_M4_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_M4_BUILT}: ${CUI_M4_CONFIGURED}
	( cd ${CUI_M4_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_M4_INSTALLED}: ${NTI_M4_BUILT}
	( cd ${NTI_M4_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-m4
nti-m4: ${NTI_M4_INSTALLED}

.PHONY: NTI
NTI: ${NTI_M4_INSTALLED}


${CUI_M4_INSTALLED}: ${CUI_M4_BUILT}
	( cd ${CUI_M4_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-m4
cui-m4: ${CUI_M4_INSTALLED}

.PHONY: CUI
CUI: ${CUI_M4_INSTALLED}
