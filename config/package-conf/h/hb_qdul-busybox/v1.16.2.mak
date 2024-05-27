#!/usr/bin/make
# hb_qdul-busybox v1.16.2   	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-28

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_BUSYBOX_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CUI_BUSYBOX_CONFIGURED= ${CUI_BUSYBOX_SRCROOT}/busybox.links
CUI_BUSYBOX_BUILT=	${CUI_BUSYBOX_SRCROOT}/busybox
CUI_BUSYBOX_INSTALLED=	${INSTTEMP}/bin/busybox


## ,-----
## |	Configure
## +-----

${CUI_BUSYBOX_CONFIGURED}:
	( cd source/busybox-${PKGVER} || exit 1 ;\
		 [ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		 cat Makefile.OLD \
		  	| sed   ' /^ARCH/       	s%=.*%= '${TARGCPU}'%' \
		  	| sed   ' /^CROSS_COMPILE/      s%=.*%= '${TARGSPEC}'-%' \
		  	> Makefile || exit 1 ;\
		( cat scripts/defconfig \
			| sed '/CONFIG_PREFIX/		s%".*"%"'${INSTTEMP}'"%' \
			| sed '/^CONFIG_LFS/		s/^/# /' \
			| sed '/^CONFIG_FEATURE_ASSUME_UNICODE/	s/^/# /' \
			| sed '/^CONFIG_FDISK_SUPPORT_LARGE_DISKS/	s/^/# /' \
			| sed '/^CONFIG_FLASHCP/	s/^/# /' \
			| sed '/^CONFIG_FLASH_LOCK/	s/^/# /' \
			| sed '/^CONFIG_FLASH_UNLOCK/	s/^/# /' \
			| sed '/^CONFIG_FLASH_ERASEALL/	s/^/# /' \
			| sed '/^CONFIG_INOTIFYD/	s/^/# /' \
			| sed '/^CONFIG_TASKSET/	s/^/# /' \
			\
			| sed '/^# /		s/=y/ is not set/' \
			| sed '/^CONFIG.*not set/	s/is not set/=y/' \
		) > .config ;\
		yes '' | ( make HOSTCC=/usr/bin/gcc oldconfig ) || exit 1 \
	)
#			| sed '/^CONFIG_EXPAND/	s/^/# /'


## ,-----
## |	Build
## +-----

${CUI_BUSYBOX_BUILT}: ${CUI_BUSYBOX_CONFIGURED}
	( cd source/busybox-${PKGVER} || exit 1 ;\
		make KBUILD_VERBOSE=1 \
	)


## ,-----
## |	Install
## +-----

# Ensure we have appropriate symlinks for the kernel compiler later
${CUI_BUSYBOX_INSTALLED}: ${CUI_BUSYBOX_BUILT}
	( cd source/busybox-${PKGVER} || exit 1 ;\
		make install \
	)

.PHONY: cui-busybox
cui-busybox: ${CUI_BUSYBOX_INSTALLED}

.PHONY: CUI
CUI: cui-busybox
