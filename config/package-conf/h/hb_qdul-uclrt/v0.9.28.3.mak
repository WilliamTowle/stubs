#!/usr/bin/make
# hb_qdul-uclrt v0.9.28.3   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-28

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_UCLRT_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_UCLRT_CONFIGURED	= ${CUI_UCLRT_SRCROOT}/.config
CUI_UCLRT_BUILT		= ${CUI_UCLRT_SRCROOT}/lib/libc.so
CUI_UCLRT_INSTALLED	= ${INSTTEMP}/lib/libc.so.0


## ,-----
## |	Configure
## +-----

${CUI_UCLRT_CONFIGURED}:
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		cp ${TCTREE}/etc/config-uClibc-${PKGVER} .config || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig \
	)


## ,-----
## |	Build
## +-----

${CUI_UCLRT_BUILT}: ${CUI_UCLRT_CONFIGURED}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		make \
	)


## ,-----
## |	Install
## +-----

# NB. PREFIX gets 'usr' added -- due to DEVEL_PREFIX
${CUI_UCLRT_INSTALLED}: ${CUI_UCLRT_BUILT}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		make PREFIX=${INSTTEMP} install_runtime \
	)

.PHONY: cui-uclrt
cui-uclrt: ${CUI_UCLRT_INSTALLED}

.PHONY: CUI
CUI: ${CUI_UCLRT_INSTALLED}
