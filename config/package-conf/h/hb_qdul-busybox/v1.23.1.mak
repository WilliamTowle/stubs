#!/usr/bin/make
# hb_qdul-busybox v1.22.1   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-03-01

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
		(	echo 'CONFIG_PREFIX="'${INSTTEMP}'"' ;\
			echo '# CONFIG_STATIC is not set' ;\
			echo 'CONFIG_FEATURE_SH_IS_ASH=y' ;\
			echo 'CONFIG_ASH=y' ;\
			echo '# CONFIG_FEATURE_IPV6 is not set' ;\
			echo 'CONFIG_FEATURE_USE_INITTAB=y' ;\
			echo 'CONFIG_INIT=y' ;\
			echo 'CONFIG_CAT=y' ;\
			echo 'CONFIG_HALT=y' ;\
			echo '# CONFIG_INETD is not set' ;\
			echo '# CONFIG_NSLOOKUP is not set' ;\
			echo 'CONFIG_REBOOT=y' ;\
			echo 'CONFIG_IFCONFIG=y' ;\
			echo 'CONFIG_LS=y' ;\
			echo '# CONFIG_NANDWRITE is not set' ;\
			echo '# CONFIG_NANDDUMP is not set' ;\
			echo '# CONFIG_PATCH is not set' ;\
			echo 'CONFIG_ROUTE=y' ;\
			echo 'CONFIG_STTY=y' ;\
			echo '# CONFIG_UBIATTACH is not set' ;\
			echo '# CONFIG_UBIDETACH is not set' ;\
			echo '# CONFIG_UBIMKVOL is not set' ;\
			echo '# CONFIG_UBIRMVOL is not set' ;\
			echo '# CONFIG_UBIRSVOL is not set' ;\
			echo '# CONFIG_UBIUPDATEVOL is not set' \
		) > .config ;\
		yes '' | ( make HOSTCC=/usr/bin/gcc oldconfig ) || exit 1 \
	)


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
CUI: ${CUI_BUSYBOX_INSTALLED}
