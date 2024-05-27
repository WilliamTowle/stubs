#!/usr/bin/make
# bison v2.4.1		   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-12-23

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_BISON_SRCROOT	= ${BUILDROOT}/NTI-bison-${PKGVER}/source/${PKGNAME}-${PKGVER}
CUI_BISON_SRCROOT	= ${BUILDROOT}/CUI-bison-${PKGVER}/source/${PKGNAME}-${PKGVER}

NTI_BISON_CONFIGURED=	${NTI_BISON_SRCROOT}/config.log
NTI_BISON_BUILT=	${NTI_BISON_SRCROOT}/src/bison
NTI_BISON_INSTALLED=	${TCTREE}/usr/bin/bison

CUI_BISON_CONFIGURED=	${CUI_BISON_SRCROOT}/config.log
CUI_BISON_BUILT=	${CUI_BISON_SRCROOT}/src/bison
CUI_BISON_INSTALLED=	${INSTTEMP}/usr/bin/bison


## ,-----
## |	Configure
## +-----

${NTI_BISON_CONFIGURED}:
	( cd ${NTI_BISON_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_BISON_CONFIGURED}:
	( cd ${CUI_BISON_SRCROOT} || exit 1 ;\
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

${NTI_BISON_BUILT}: ${NTI_BISON_CONFIGURED}
	( cd ${NTI_BISON_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_BISON_BUILT}: ${CUI_BISON_CONFIGURED}
	( cd ${CUI_BISON_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_BISON_INSTALLED}: ${NTI_BISON_BUILT}
	( cd ${NTI_BISON_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-bison
nti-bison: ${NTI_BISON_INSTALLED}

.PHONY: NTI
NTI: ${NTI_BISON_INSTALLED}


${CUI_BISON_INSTALLED}: ${CUI_BISON_BUILT}
	( cd ${CUI_BISON_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-bison
cui-bison: ${CUI_BISON_INSTALLED}

.PHONY: CUI
CUI: ${CUI_BISON_INSTALLED}
