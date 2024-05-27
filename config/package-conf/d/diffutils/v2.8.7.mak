#!/usr/bin/make
# diffutils v2.8.7	   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-12-12

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_DIFFUTILS_SRCROOT	= ${BUILDROOT}/NTI-diffutils-${PKGVER}/source/diffutils-${PKGVER}
CUI_DIFFUTILS_SRCROOT	= ${BUILDROOT}/CUI-diffutils-${PKGVER}/source/diffutils-${PKGVER}

# STUBS: source extracted by controlling script

NTI_DIFFUTILS_CONFIGURED=	${NTI_DIFFUTILS_SRCROOT}/config.log
NTI_DIFFUTILS_BUILT=		${NTI_DIFFUTILS_SRCROOT}/src/diff
NTI_DIFFUTILS_INSTALLED=	${NTI_TC_ROOT}/usr/bin/diff

CUI_DIFFUTILS_CONFIGURED=	${CUI_DIFFUTILS_SRCROOT}/config.log
CUI_DIFFUTILS_BUILT=		${CUI_DIFFUTILS_SRCROOT}/src/diff
CUI_DIFFUTILS_INSTALLED=	${INSTTEMP}/bin/diff


## ,-----
## |	Configure
## +-----

${NTI_DIFFUTILS_CONFIGURED}:
	( cd ${NTI_DIFFUTILS_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_DIFFUTILS_CONFIGURED}:
	( cd ${CUI_DIFFUTILS_SRCROOT} || exit 1 ;\
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

${NTI_DIFFUTILS_BUILT}: ${NTI_DIFFUTILS_CONFIGURED}
	( cd ${NTI_DIFFUTILS_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_DIFFUTILS_BUILT}: ${CUI_DIFFUTILS_CONFIGURED}
	( cd ${CUI_DIFFUTILS_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_DIFFUTILS_INSTALLED}: ${NTI_DIFFUTILS_BUILT}
	( cd ${NTI_DIFFUTILS_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-diffutils
nti-diffutils: ${NTI_DIFFUTILS_INSTALLED}

.PHONY: NTI
NTI: ${NTI_DIFFUTILS_INSTALLED}


${CUI_DIFFUTILS_INSTALLED}: ${CUI_DIFFUTILS_BUILT}
	( cd ${CUI_DIFFUTILS_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-diffutils
cui-diffutils: ${CUI_DIFFUTILS_INSTALLED}

.PHONY: CUI
CUI: ${CUI_DIFFUTILS_INSTALLED}
