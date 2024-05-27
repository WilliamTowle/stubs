#!/usr/bin/make
# hb_qdul-lxheaders v2.6.20.1  	STUBS (c) and GPLv2 1999-2012
# last modified			2012-09-05

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_LXHEADERS_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_LXHEADERS_CONFIGURED	= ${CUI_LXHEADERS_SRCROOT}/.config
CUI_LXHEADERS_BUILT		= ${CUI_LXHEADERS_SRCROOT}/.missing-syscalls.d
CUI_LXHEADERS_INSTALLED		= ${INSTTEMP}/usr/include/linux


## ,-----
## |	Configure
## +-----

${CUI_LXHEADERS_CONFIGURED}:
	( cd source/linux-${PKGVER} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^ARCH/		s/?=.*/:= '${TARGCPU}'/' \
			| sed '/^CROSS_COMPILE/	s/?=.*/:= '${TARGSPEC}'-k/' \
		> Makefile ;\
		make mrproper ;\
		cp ${TCTREE}/etc/config-kernel-${PKGVER} .config || exit 1 \
	)


## ,-----
## |	Build
## +-----

${CUI_LXHEADERS_BUILT}: ${CUI_LXHEADERS_CONFIGURED}
	( cd source/linux-${PKGVER} || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig ;\
	 	make ARCH=${TARGCPU} prepare \
	)


## ,-----
## |	Install
## +-----

${CUI_LXHEADERS_INSTALLED}: ${CUI_LXHEADERS_BUILT}
	mkdir -p ${INSTTEMP}/usr/include
	( cd source/linux-${PKGVER} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGCPU} asm-generic linux ) | ( cd ${INSTTEMP}/usr/include/ && tar xf - ) \
	)

.PHONY: cui-lxheaders
cui-lxheaders: ${CUI_LXHEADERS_INSTALLED}

.PHONY: CUI
CUI: ${CUI_LXHEADERS_INSTALLED}
