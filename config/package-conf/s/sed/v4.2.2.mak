#!/usr/bin/make
# sed v4.2.2		   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-02

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_SED_SRCROOT	= ${BUILDROOT}/NTI-sed-${PKGVER}/source/sed-${PKGVER}
CUI_SED_SRCROOT	= ${BUILDROOT}/CUI-sed-${PKGVER}/source/sed-${PKGVER}

# STUBS: source extracted by controlling script

NTI_SED_CONFIGURED=	${NTI_SED_SRCROOT}/config.log
NTI_SED_BUILT=		${NTI_SED_SRCROOT}/sed
NTI_SED_INSTALLED=	${TCTREE}/usr/bin/sed

CUI_SED_CONFIGURED=	${CUI_SED_SRCROOT}/config.log
CUI_SED_BUILT=		${CUI_SED_SRCROOT}/sed
CUI_SED_INSTALLED=	${INSTTEMP}/bin/sed


## ,-----
## |	Configure
## +-----

${NTI_SED_CONFIGURED}:
	( cd ${NTI_SED_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --without-included-regex \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_SED_CONFIGURED}:
	( cd ${CUI_SED_SRCROOT} || exit 1 ;\
		./configure --prefix=/usr --bindir=/bin \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} \
			  --without-included-regex \
			  --disable-largefile --disable-nls ;\
		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1 ;\
		cat config.h.OLD \
			| sed '/define HAVE_MBRTOWC/	{ s/ 1// ; s/define/undef/ } ' \
			| sed '/define HAVE_MBSTATE_T/	{ s/ 1// ; s/define/undef/ } ' \
			| sed '/define HAVE_WCHAR_H/	{ s/ 1// ; s/define/undef/ } ' \
			| sed '/undef mbstate_t/	{ s/undef/define/ ; s/mbstate_t.*/mbstate_t char/ }' \
			| sed '/define ENABLE_NLS/	{ s/ 1// ; s/define/undef/ } ' \
			> config.h || exit 1 \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${NTI_SED_BUILT}: ${NTI_SED_CONFIGURED}
	( cd ${NTI_SED_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_SED_BUILT}: ${CUI_SED_CONFIGURED}
	( cd ${CUI_SED_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_SED_INSTALLED}: ${NTI_SED_BUILT}
	( cd ${NTI_SED_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-sed
nti-sed: ${NTI_SED_INSTALLED}

.PHONY: NTI
NTI: ${NTI_SED_INSTALLED}


${CUI_SED_INSTALLED}: ${CUI_SED_BUILT}
	( cd ${CUI_SED_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-sed
cui-sed: ${CUI_SED_INSTALLED}

.PHONY: CUI
CUI: ${CUI_SED_INSTALLED}
