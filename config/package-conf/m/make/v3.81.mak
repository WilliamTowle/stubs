#!/usr/bin/make
# make v3.81		   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-12-12

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_MAKE_SRCROOT	= ${BUILDROOT}/NTI-make-${PKGVER}/source/make-${PKGVER}
CUI_MAKE_SRCROOT	= ${BUILDROOT}/CUI-make-${PKGVER}/source/make-${PKGVER}

# STUBS: source extracted by controlling script

NTI_MAKE_CONFIGURED=	${NTI_MAKE_SRCROOT}/config.status
NTI_MAKE_BUILT=		${NTI_MAKE_SRCROOT}/make
NTI_MAKE_INSTALLED=	${TCTREE}/usr/bin/make

CUI_MAKE_CONFIGURED=	${CUI_MAKE_SRCROOT}/config.status
CUI_MAKE_BUILT=		${CUI_MAKE_SRCROOT}/make
CUI_MAKE_INSTALLED=	${INSTTEMP}/usr/bin/make


## ,-----
## |	Configure
## +-----

${NTI_MAKE_CONFIGURED}:
	( cd ${NTI_MAKE_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


${CUI_MAKE_CONFIGURED}:
	( cd ${CUI_MAKE_SRCROOT} || exit 1 ;\
		./configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} \
			  --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${NTI_MAKE_BUILT}: ${NTI_MAKE_CONFIGURED}
	( cd ${NTI_MAKE_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_MAKE_BUILT}: ${CUI_MAKE_CONFIGURED}
	( cd ${CUI_MAKE_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_MAKE_INSTALLED}: ${NTI_MAKE_BUILT}
	( cd ${NTI_MAKE_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-make
nti-make: ${NTI_MAKE_INSTALLED}

.PHONY: NTI
NTI: ${NTI_MAKE_INSTALLED}

${NTI_SED_INSTALLED}: ${NTI_SED_BUILT}
	( cd ${CUI_MAKE_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-sed
nti-sed: ${NTI_SED_INSTALLED}

.PHONY: NTI
NTI: ${NTI_SED_INSTALLED}


# Ensure we have appropriate symlinks for the kernel compiler later
${CUI_MAKE_INSTALLED}: ${CUI_MAKE_BUILT}
	( cd ${CUI_MAKE_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-make
cui-make: ${CUI_MAKE_INSTALLED}

.PHONY: CUI
CUI: ${CUI_MAKE_INSTALLED}
