#!/usr/bin/make
# bc v1.06		   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-06

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_BC_SRCROOT	= ${BUILDROOT}/NTI-bc-${PKGVER}/source/bc-${PKGVER}

# STUBS: source extracted by controlling script

NTI_BC_CONFIGURED=	${NTI_BC_SRCROOT}/config.log
NTI_BC_BUILT=		${NTI_BC_SRCROOT}/bc
NTI_BC_INSTALLED=	${TCTREE}/usr/bin/bc


## ,-----
## |	Configure
## +-----

${NTI_BC_CONFIGURED}:
	( cd ${NTI_BC_SRCROOT} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr \
			  --without-included-regex \
			  --disable-largefile --disable-nls \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${NTI_BC_BUILT}: ${NTI_BC_CONFIGURED}
	( cd ${NTI_BC_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_BC_INSTALLED}: ${NTI_BC_BUILT}
	( cd ${NTI_BC_SRCROOT} || exit 1 ;\
		make install \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-bc
nti-bc: ${NTI_BC_INSTALLED}

.PHONY: NTI
NTI: ${NTI_BC_INSTALLED}
