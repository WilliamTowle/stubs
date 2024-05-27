#!/usr/bin/make
# hb_qdul-lxbinary v2.6.20.1   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-09-03

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_LXBINARY_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

CUI_LXBINARY_CONFIGURED	= ${CUI_LXBINARY_SRCROOT}/.config
# NB. bzImage for TARGCPU=i386; differs otherwise
CUI_LXBINARY_BUILT	= ${CUI_LXBINARY_SRCROOT}/arch/x86/boot/bzImage
#CUI_LXBINARY_BUILT	= ${CUI_LXBINARY_SRCROOT}/vmlinux
CUI_LXBINARY_INSTALLED	= ${TCTREE}/etc/vmlinux-${PKGVER}


## ,-----
## |	Configure
## +-----

${CUI_LXBINARY_CONFIGURED}:
	( cd ${CUI_LXBINARY_SRCROOT} || exit 1 ;\
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

${CUI_LXBINARY_BUILT}: ${CUI_LXBINARY_CONFIGURED}
	( cd ${CUI_LXBINARY_SRCROOT} || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig ;\
		make archprepare || exit 1;\
		make bzImage \
	)


## ,-----
## |	Install
## +-----

${CUI_LXBINARY_INSTALLED}: ${CUI_LXBINARY_BUILT}
	( cd ${CUI_LXBINARY_SRCROOT} || exit 1 ;\
		cp ${CUI_LXBINARY_BUILT} ${CUI_LXBINARY_INSTALLED} \
	)

.PHONY: cui-lxbinary
cui-lxbinary: ${CUI_LXBINARY_INSTALLED}

.PHONY: CUI
CUI: ${CUI_LXBINARY_INSTALLED}
