#!/usr/bin/make
# findutils v4.4.2	   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-02

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_FINDUTILS_SRCROOT	= ${BUILDROOT}/NTI-findutils-${PKGVER}/source/${PKGNAME}-${PKGVER}
CUI_FINDUTILS_SRCROOT	= ${BUILDROOT}/CUI-findutils-${PKGVER}/source/${PKGNAME}-${PKGVER}

NTI_FINDUTILS_CONFIGURED=	${NTI_FINDUTILS_SRCROOT}/config.log
NTI_FINDUTILS_BUILT=		${NTI_FINDUTILS_SRCROOT}/find/find
NTI_FINDUTILS_INSTALLED=	${TCTREE}/usr/bin/find

CUI_FINDUTILS_CONFIGURED=	${CUI_FINDUTILS_SRCROOT}/config.log
CUI_FINDUTILS_BUILT=		${CUI_FINDUTILS_SRCROOT}/find/find
CUI_FINDUTILS_INSTALLED=	${INSTTEMP}/usr/bin/find


## ,-----
## |	Configure
## +-----

${NTI_FINDUTILS_CONFIGURED}:
	( cd ${NTI_FINDUTILS_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_FINDUTILS_CONFIGURED}:
	( cd ${CUI_FINDUTILS_SRCROOT} || exit 1 ;\
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

${NTI_FINDUTILS_BUILT}: ${NTI_FINDUTILS_CONFIGURED}
	( cd ${NTI_FINDUTILS_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_FINDUTILS_BUILT}: ${CUI_FINDUTILS_CONFIGURED}
	( cd ${CUI_FINDUTILS_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_FINDUTILS_INSTALLED}: ${NTI_FINDUTILS_BUILT}
	( cd ${NTI_FINDUTILS_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-findutils
nti-findutils: ${NTI_FINDUTILS_INSTALLED}

.PHONY: NTI
NTI: ${NTI_FINDUTILS_INSTALLED}


${CUI_FINDUTILS_INSTALLED}: ${CUI_FINDUTILS_BUILT}
	( cd ${CUI_FINDUTILS_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-findutils
cui-findutils: ${CUI_FINDUTILS_INSTALLED}

.PHONY: CUI
CUI: ${CUI_FINDUTILS_INSTALLED}
