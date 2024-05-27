#!/usr/bin/make
# hb_qdtc-lxheaders v2.6.20.1  	STUBS (c) and GPLv2 1999-2012
# last modified			2012-08-23

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_LXHEADERS_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_LXHEADERS_CONFIGURED	= ${CTI_LXHEADERS_SRCROOT}/.config
CTI_LXHEADERS_BUILT		= ${CTI_LXHEADERS_SRCROOT}/.missing-syscalls.d
CTI_LXHEADERS_INSTALLED		= ${TCTREE}/etc/config-kernel-${PKGVER}


## ,-----
## |	Configure
## +-----

${CTI_LXHEADERS_CONFIGURED}:
	( cd source/linux-${PKGVER} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^ARCH/		s/?=.*/:= '${TARGCPU}'/' \
			| sed '/^CROSS_COMPILE/	s/?=.*/:= '${TARGSPEC}'-k/' \
		> Makefile ;\
		make mrproper ;\
			if [ -d arch/x86 ] ; then \
				cat arch/x86/configs/i386_defconfig ;\
			else \
				cat arch/${TARGCPU}/defconfig ;\
			fi \
		                | sed   '/^CONFIG_MPENTIUM4/	s/^/# /' \
		                | sed   '/^CONFIG_M.86/          s/^/# /' \
		                | sed   '/CONFIG_LOCALVERSION/  s/""/"mine"/' \
		                | sed   '/CONFIG_IKCONFIG/      s/^/# /' \
		                | sed   '/CONFIG_MATH_EMULATION/ s/^# //' \
		                | sed   '/CONFIG_SOFTWARE_SUSPEND/ s/^/# /' \
		                | sed   '/CONFIG_BLK_DEV_LOOP/ s/^# //' \
		                | sed   '/CONFIG_BLK_DEV_RAM/ s/^# //' \
		                | sed   '/CONFIG_BLK_DEV_INITRD/ s/^# //' \
		                | sed   '/CONFIG_MINIX_FS/ s/^# //' \
		                | sed   '/CONFIG_HOTPLUG_PCI/ s/^# //' \
		                | sed   '/CONFIG_PCIEPORTBUS/ s/^# //' \
		                | sed   '/^CONFIG.*not set/     s/ is not set/=y/ ; /^#.*=y/            s/=y/ is not set/ ' \
		                | sed   '/^# # /		s/# //' \
		                > .config ;\
		                echo "CONFIG_HOTPLUG_PCI_PCIE=y" >> .config ;\
		                echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config ;\
		                echo "CONFIG_APM_DO_ENABLE=y" >> .config ;\
		                echo "CONFIG_APM_CPU_IDLE=y" >> .config ;\
		                echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config ;\
		                echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config ;\
		                echo "CONFIG_APM_ALLOW_INTS=y" >> .config ;\
		                echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config \
	)


## ,-----
## |	Build
## +-----

# v2.x kernels need "dep" (2.0 to 2.4) or "prepare" *as part of build*
# v3.x can just do 'oldconfig'

ifeq (${TARGCPU},mipsel)	# sole *relevant* exception, one of many
LXHEADERS_ARCH_OPTS:=ARCH=mips
else
LXHEADERS_ARCH_OPTS:=ARCH=${TARGCPU}
endif

${CTI_LXHEADERS_BUILT}: ${CTI_LXHEADERS_CONFIGURED}
	( cd source/linux-${PKGVER} || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig ;\
		make ${LXHEADERS_ARCH_OPTS} prepare \
	)


## ,-----
## |	Install
## +-----

# v2.x kernels are best set up manually,
# v3.x kernels have a "headers_install" rule

${CTI_LXHEADERS_INSTALLED}: ${CTI_LXHEADERS_BUILT}
	mkdir -p ${TCTREE}/usr/${TARGSPEC}/usr/include
	mkdir -p ${TCTREE}/usr/${TARGSPEC}/usr/src/linux-${PKGVER}
	( cd source/linux-${PKGVER} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGCPU} asm-generic linux ) | ( cd ${TCTREE}/usr/${TARGSPEC}/usr/include/ && tar xf - ) ;\
		( cd ${TCTREE}/usr/${TARGSPEC}/usr/src && ln -sf linux-${PKGVER} linux ) || exit 1 ;\
		tar cvf - ./ | ( cd ${TCTREE}/usr/${TARGSPEC}/usr/src/linux && tar xvf - ) ;\
		mkdir -p ${TCTREE}/etc ;\
		cp .config ${CTI_LXHEADERS_INSTALLED} \
	)

.PHONY: cti-lxheaders
cti-lxheaders: ${CTI_LXHEADERS_INSTALLED}

.PHONY: CTI
CTI: ${CTI_LXHEADERS_INSTALLED}
