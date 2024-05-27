#!/usr/bin/make
# coreutils v8.22	   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-02

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_COREUTILS_SRCROOT	= ${BUILDROOT}/NTI-coreutils-${PKGVER}/source/coreutils-${PKGVER}
CUI_COREUTILS_SRCROOT	= ${BUILDROOT}/CUI-coreutils-${PKGVER}/source/coreutils-${PKGVER}

# STUBS: source extracted by controlling script

NTI_COREUTILS_CONFIGURED=	${NTI_COREUTILS_SRCROOT}/config.log
NTI_COREUTILS_BUILT=		${NTI_COREUTILS_SRCROOT}/src/sync
NTI_COREUTILS_INSTALLED=	${TCTREE}/usr/bin/sync

CUI_COREUTILS_CONFIGURED=	${CUI_COREUTILS_SRCROOT}/config.log
CUI_COREUTILS_BUILT=		${CUI_COREUTILS_SRCROOT}/src/sync
CUI_COREUTILS_INSTALLED=	${INSTTEMP}/usr/bin/sync


## ,-----
## |	Configure
## +-----

${NTI_COREUTILS_CONFIGURED}:
	( cd ${NTI_COREUTILS_SRCROOT} || exit 1 ;\
		ac_cv_func_getloadavg=no \
		ac_cv_func_working_mktime=no \
		  ./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_COREUTILS_CONFIGURED}:
	( cd ${CUI_COREUTILS_SRCROOT} || exit 1 ;\
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

${NTI_COREUTILS_BUILT}: ${NTI_COREUTILS_CONFIGURED}
	( cd ${NTI_COREUTILS_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_COREUTILS_BUILT}: ${CUI_COREUTILS_CONFIGURED}
	( cd ${CUI_COREUTILS_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_COREUTILS_INSTALLED}: ${NTI_COREUTILS_BUILT}
	( cd ${NTI_COREUTILS_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-coreutils
nti-coreutils: ${NTI_COREUTILS_INSTALLED}

.PHONY: NTI
NTI: ${NTI_COREUTILS_INSTALLED}


${CUI_COREUTILS_INSTALLED}: ${CUI_COREUTILS_BUILT}
	( cd ${CUI_COREUTILS_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-coreutils
cui-coreutils: ${CUI_COREUTILS_INSTALLED}

.PHONY: CUI
CUI: ${CUI_COREUTILS_INSTALLED}
