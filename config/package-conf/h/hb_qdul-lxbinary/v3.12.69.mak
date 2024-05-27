#!/usr/bin/make
# hb_qdul-lxbinary v3.12.51  	STUBS (c) and GPLv2 1999-2016
# last modified			2016-01-17

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_LXBINARY_SRCROOT	= ${BUILDROOT}/CUI-${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

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
		make prepare || exit 1;\
		grep 'CONFIG_MODULES=y' ${TCTREE}/etc/config-kernel-${PKGVER} .config 2>/dev/null && make modules ;\
		make bzImage \
	)


## ,-----
## |	Install
## +-----

## [2014-05-18] also copy modules
## [2016-01-16] 1001PX has various sound modules built, loaded... should we?

${CUI_LXBINARY_INSTALLED}: ${CUI_LXBINARY_BUILT}
	( cd ${CUI_LXBINARY_SRCROOT} || exit 1 ;\
		find */. -name '*ko' ;\
		for F in ./drivers/misc/eeprom/eeprom_93cx6.ko ./drivers/staging/rtl8187se/r8187se.ko \
			./sound/pci/snd*ko ./sound/pci/ac97/snd*ko ./sound/pci/hda/snd*ko \
			./sound/ac97*ko sound/drivers/mpu401/snd*ko \
			./sound/core/snd*ko ./sound/core/oss/snd*ko ./sound/core/seq/snd*ko ./sound/core/seq/oss/snd*ko \
		; do \
			INSTALLDIR=${INSTTEMP}/lib/modules/${PKGVER}/`dirname $${F}` ;\
			if [ -e $${F} ] ; then mkdir -p $${INSTALLDIR} && cp $${F} $${INSTALLDIR} ; fi ;\
		done || exit 1 ;\
		cp ${CUI_LXBINARY_BUILT} ${CUI_LXBINARY_INSTALLED} \
	)

.PHONY: cui-lxbinary
cui-lxbinary: ${CUI_LXBINARY_INSTALLED}

.PHONY: CUI
CUI: ${CUI_LXBINARY_INSTALLED}
