#!/usr/bin/make
# hb_qdul-lxsource v3.9.11   	STUBS (c) and GPLv2 1999-2013
# last modified			2013-12-29

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_LXSOURCE_SRCROOT	= ${BUILDTEMP}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_LXSOURCE_CONFIGURED	= ${CUI_LXSOURCE_SRCROOT}/.config
CUI_LXSOURCE_BUILT	= ${CUI_LXSOURCE_SRCROOT}/.missing-syscalls.d
CUI_LXSOURCE_INSTALLED	= ${INSTTEMP}/usr/include/linux


## ,-----
## |	Configure
## +-----

${CUI_LXSOURCE_CONFIGURED}:
	( cd ${CUI_LXSOURCE_SRCROOT} || exit 1 ;\
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

# [2012-12-02] `make prepare` for linux/version.h ...?
# ...needs cross compiler for this.

${CUI_LXSOURCE_BUILT}: ${CUI_LXSOURCE_CONFIGURED}
	( cd ${CUI_LXSOURCE_SRCROOT} || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig ;\
		make prepare \
	)


## ,-----
## |	Install
## +-----

${CUI_LXSOURCE_INSTALLED}: ${CUI_LXSOURCE_BUILT}
	( cd ${CUI_LXSOURCE_SRCROOT} || exit 1 ;\
		mkdir -p ${INSTTEMP}/usr/src/linux-${PKGVER} || exit 1 ;\
		( cd ${INSTTEMP}/usr/src && ln -sf linux-${PKGVER} linux ) || exit 1 ;\
		( tar cvf - .config * ) | ( cd ${INSTTEMP}/usr/src/linux-${PKGVER} && tar xvf - ) \
	)

.PHONY: cui-lxsource
cui-lxsource: ${CUI_LXSOURCE_INSTALLED}

.PHONY: CUI
CUI: ${CUI_LXSOURCE_INSTALLED}
