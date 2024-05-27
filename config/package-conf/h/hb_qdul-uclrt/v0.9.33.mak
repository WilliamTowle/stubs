#!/usr/bin/make
# hb_qdul-uclrt v0.9.33.2   	STUBS (c) and GPLv2 1999-2012
# last modified			2014-01-03

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

# Since v0.9.33.2:
# - trigger 'install_utils' (for ldconfig, ldd)

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
		make PREFIX=${INSTTEMP} install_runtime install_utils \
	)

.PHONY: cui-uclrt
cui-uclrt: ${CUI_UCLRT_INSTALLED}

.PHONY: CUI
CUI: ${CUI_UCLRT_INSTALLED}
