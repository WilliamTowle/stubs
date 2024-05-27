#!/usr/bin/make
# hb_qdul-ucldev v0.9.33.2   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-27

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_UCLDEV_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_UCLDEV_CONFIGURED	= ${CUI_UCLDEV_SRCROOT}/.config
CUI_UCLDEV_BUILT	= ${CUI_UCLDEV_SRCROOT}/lib/ld-uClibc-0.9.33.2.so
CUI_UCLDEV_INSTALLED	= ${TCTREE}/etc/config-uClibc-${PKGVER}


## ,-----
## |	Configure
## +-----

${CUI_UCLDEV_CONFIGURED}:
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		cp ${TCTREE}/etc/config-uClibc-${PKGVER} .config || exit 1 ;\
                yes '' | ${MAKE} HOSTCC=/usr/bin/gcc oldconfig \
	)


## ,-----
## |	Build
## +-----

${CUI_UCLDEV_BUILT}: ${CUI_UCLDEV_CONFIGURED}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		${MAKE} || exit 1 \
	)


## ,-----
## |	Install
## +-----

# install_headers for /usr/include
# install_dev does headers, runtime, startfiles
# install_startfiles for /usr/lib

${CUI_UCLDEV_INSTALLED}: ${CUI_UCLDEV_BUILT}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		${MAKE} PREFIX=${INSTTEMP} install_dev \
	)

.PHONY: cui-ucldev
cui-ucldev: ${CUI_UCLDEV_INSTALLED}

.PHONY: CUI
CUI: cui-ucldev
