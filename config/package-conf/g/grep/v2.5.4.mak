#!/usr/bin/make
# grep v2.5.4		   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-12-23

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_GREP_SRCROOT	= ${BUILDROOT}/NTI-grep-${PKGVER}/source/grep-${PKGVER}
CUI_GREP_SRCROOT	= ${BUILDROOT}/CUI-grep-${PKGVER}/source/grep-${PKGVER}

# STUBS: source extracted by controlling script

NTI_GREP_CONFIGURED=	${NTI_GREP_SRCROOT}/config.log
NTI_GREP_BUILT=		${NTI_GREP_SRCROOT}/src/grep
NTI_GREP_INSTALLED=	${NTI_TC_ROOT}/usr/bin/grep

CUI_GREP_CONFIGURED=	${CUI_GREP_SRCROOT}/config.log
CUI_GREP_BUILT=		${CUI_GREP_SRCROOT}/src/grep
CUI_GREP_INSTALLED=	${INSTTEMP}/bin/grep


## ,-----
## |	Configure
## +-----

# grep 2.5.3: Wants 'makeinfo' unless all-recursive descends into doc/

${NTI_GREP_CONFIGURED}:
	( cd ${NTI_GREP_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@
# [grep 2.5.3] problem with 'makeinfo' when missing
#	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
#	cat Makefile.OLD \
#		| sed '/^SUBDIRS/	s/doc//' \
#		> Makefile \


${CUI_GREP_CONFIGURED}:
	( cd ${CUI_GREP_SRCROOT} || exit 1 ;\
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

${NTI_GREP_BUILT}: ${NTI_GREP_CONFIGURED}
	( cd ${NTI_GREP_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_GREP_BUILT}: ${CUI_GREP_CONFIGURED}
	( cd ${CUI_GREP_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_GREP_INSTALLED}: ${NTI_GREP_BUILT}
	( cd ${NTI_GREP_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-grep
nti-grep: ${NTI_GREP_INSTALLED}

.PHONY: NTI
NTI: ${NTI_GREP_INSTALLED}


${CUI_GREP_INSTALLED}: ${CUI_GREP_BUILT}
	( cd ${CUI_GREP_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-grep
cui-grep: ${CUI_GREP_INSTALLED}

.PHONY: CUI
CUI: ${CUI_GREP_INSTALLED}
