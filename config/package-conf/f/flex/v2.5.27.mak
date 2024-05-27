#!/usr/bin/make
# flex v2.5.27		   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-12-12

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_FLEX_SRCROOT	= ${BUILDROOT}/NTI-flex-${PKGVER}/source/flex-${PKGVER}
CUI_FLEX_SRCROOT	= ${BUILDROOT}/CUI-flex-${PKGVER}/source/flex-${PKGVER}

# STUBS: source extracted by controlling script

NTI_FLEX_CONFIGURED=	${NTI_FLEX_SRCROOT}/config.log
NTI_FLEX_BUILT=		${NTI_FLEX_SRCROOT}/flex
NTI_FLEX_INSTALLED=	${TCTREE}/usr/bin/flex

CUI_FLEX_CONFIGURED=	${CUI_FLEX_SRCROOT}/config.log
CUI_FLEX_BUILT=		${CUI_FLEX_SRCROOT}/flex
CUI_FLEX_INSTALLED=	${INSTTEMP}/bin/flex


## ,-----
## |	Configure
## +-----

${NTI_FLEX_CONFIGURED}:
	( cd ${NTI_FLEX_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_FLEX_CONFIGURED}:
	( cd ${CUI_FLEX_SRCROOT} || exit 1 ;\
		echo '*** UNTESTED ***' ; exit 1 ;\
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

${NTI_FLEX_BUILT}: ${NTI_FLEX_CONFIGURED}
	( cd ${NTI_FLEX_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_FLEX_BUILT}: ${CUI_FLEX_CONFIGURED}
	( cd ${CUI_FLEX_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_FLEX_INSTALLED}: ${NTI_FLEX_BUILT}
	( cd ${NTI_FLEX_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-flex
nti-flex: ${NTI_FLEX_INSTALLED}

.PHONY: NTI
NTI: ${NTI_FLEX_INSTALLED}


${CUI_FLEX_INSTALLED}: ${CUI_FLEX_BUILT}
	( cd ${CUI_FLEX_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-flex
cui-flex: ${CUI_FLEX_INSTALLED}

.PHONY: CUI
CUI: ${CUI_FLEX_INSTALLED}
