#!/usr/bin/make
# hb_qdul-lxheaders v3.9.11   	STUBS (c) and GPLv2 1999-2015
# last modified			2015-01-27

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_LXHEADERS_SRCROOT	= ${BUILDTEMP}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_LXHEADERS_CONFIGURED	= ${CUI_LXHEADERS_SRCROOT}/.config
CUI_LXHEADERS_BUILT		= ${CUI_LXHEADERS_SRCROOT}/.missing-syscalls.d
CUI_LXHEADERS_INSTALLED		= ${INSTTEMP}/usr/include/linux


## ,-----
## |	Configure
## +-----

## 3.8.6+: needs patch to ensure install works with long paths
## 3.10.65: 'ashfield' patch does not apply but netlink.h change required

${CUI_LXHEADERS_CONFIGURED}:
	( cd ${CUI_LXHEADERS_SRCROOT} || exit 1 ;\
		ls ${BUILDTEMP}/source/*patch* | while read PF ; do \
			echo "PATCHING: PF $${PF}" ;\
			patch -Np1 -i $${PF} || exit 1 ;\
			rm -f $${PF} ;\
		done || exit 1 ;\
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
	( cd ${CUI_LXHEADERS_SRCROOT} || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig \
	)


## ,-----
## |	Install
## +-----

${CUI_LXHEADERS_INSTALLED}: ${CUI_LXHEADERS_BUILT}
	( cd ${CUI_LXHEADERS_SRCROOT} || exit 1 ;\
		make KBUILD_VERBOSE=1 headers_install INSTALL_HDR_PATH=${INSTTEMP}/usr \
	)

.PHONY: cui-lxheaders
cui-lxheaders: ${CUI_LXHEADERS_INSTALLED}

.PHONY: CUI
CUI: ${CUI_LXHEADERS_INSTALLED}
