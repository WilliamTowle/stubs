#!/usr/bin/make
# hb_qdtc-uclrt v0.9.33.2   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-07-02

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_UCLRT_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_UCLRT_CONFIGURED	= ${CTI_UCLRT_SRCROOT}/.config
CTI_UCLRT_BUILT		= ${BUILDROOT}/${PKGNAME}-${PKGVER}/lib/libc.so
CTI_UCLRT_INSTALLED	= ${TCTREE}/etc/config-uClibc-${PKGVER}


## ,-----
## |	Configure
## +-----

${CTI_UCLRT_CONFIGURED}:
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		cp ${TCTREE}/etc/config-uClibc-${PKGVER} .config || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig \
	)


## ,-----
## |	Build
## +-----

${CTI_UCLRT_BUILT}: ${CTI_UCLRT_CONFIGURED}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		make \
	)


## ,-----
## |	Install
## +-----

# NB. PREFIX gets 'usr' added -- due to DEVEL_PREFIX
${CTI_UCLRT_INSTALLED}: ${CTI_UCLRT_BUILT}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		make PREFIX=${TCTREE}'/usr/'${TARGSPEC}'/' install \
	)

.PHONY: cti-uclrt
cti-uclrt: ${CTI_UCLRT_INSTALLED}

.PHONY: CTI
CTI: ${CTI_UCLRT_INSTALLED}
