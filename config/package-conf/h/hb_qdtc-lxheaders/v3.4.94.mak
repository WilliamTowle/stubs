#!/usr/bin/make
# hb_qdtc-lxheaders v3.9.11   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-18

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_LXHEADERS_SRCROOT	= ${BUILDTEMP}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_LXHEADERS_CONFIGURED	= ${CTI_LXHEADERS_SRCROOT}/.config
CTI_LXHEADERS_BUILT		= ${CTI_LXHEADERS_SRCROOT}/.missing-syscalls.d
CTI_LXHEADERS_INSTALLED		= ${TCTREE}/etc/config-kernel-${PKGVER}


## ,-----
## |	Configure
## +-----

## 3.4.18+: Forcibly ensure CONFIG_TMPFS is set
## 3.8.6+: needs patch to ensure install works with long paths

${CTI_LXHEADERS_CONFIGURED}:
	( cd ${CTI_LXHEADERS_SRCROOT} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^ARCH/		s/?=.*/:= '${TARGCPU}'/' \
			| sed '/^CROSS_COMPILE/	s/?=.*/:= '${TARGSPEC}'-k/' \
		> Makefile ;\
		make mrproper ;\
                cp arch/x86/configs/i386_defconfig .config || exit 1 ;\
		echo 'Standard options...' ;\
		scripts/config --enable X86 --enable X86_32 --disable X86_64 --disable 64BIT ;\
		scripts/config --enable MPENTIUMM ;\
		scripts/config --enable EMBEDDED ;\
		scripts/config --enable IKCONFIG --enable IKCONFIG_PROC ;\
		scripts/config --enable ATA --enable ATA_PIIX --enable SATA_AHCI ;\
		scripts/config --enable PCI --enable HOTPLUG_PCI --enable HOTPLUG_PCI_PCIE ;\
		scripts/config --enable BLK_DEV_HD --enable BLK_DEV_SD ;\
		scripts/config --enable USB ;\
		echo 'Early startup options...' ;\
		scripts/config --enable BLK_DEV_INITRD --enable DEVTMPFS --disable BLK_DEV_RAM ;\
		echo 'Filesystem options...' ;\
		scripts/config --enable SHMEM --enable TMPFS ;\
		scripts/config --enable EXT2_FS ;\
		scripts/config --enable AFFS_FS ;\
		echo 'Audio options...' ;\
		scripts/config --enable SND ;\
		scripts/config --enable SND_HDA_INTEL --enable SND_HDA_CODEC_REALTEK ;\
		scripts/config --enable SND_HDA_POWER_SAVE ;\
		scripts/config --enable SND_VIA82XX ;\
		echo 'Screen and I/O options...' ;\
		scripts/config --enable INPUT_MOUSEDEV_PSAUX --enable TTY ;\
		scripts/config --enable FB --enable FRAMEBUFFER_CONSOLE ;\
		scripts/config --enable FB_INTEL --enable DRM_KMS_HELPER --enable DRM_I915 --enable DRM_I915_KMS ;\
		scripts/config --enable CONFIG_FB_VIA ;\
		echo 'Miscellaneous other options...' ;\
		scripts/config --disable SECURITY_SELINUX ;\
		echo 'Networking/other options...' ;\
		scripts/config --enable ATH_COMMON --enable ATL2 --enable ATL1E ;\
		scripts/config --enable NET_VENDOR_VIA --enable VIA_RHINE ;\
		scripts/config --enable WLAN --enable CFG80211 --enable MAC80211 --enable STAGING --enable R8187SE ;\
		scripts/config --enable ATH_CARDS --enable ATH5K ;\
		scripts/config --disable ACPI ;\
		scripts/config --enable APM --enable APM_IGNORE_USER_SUSPEND --enable APM_DO_ENABLE --enable APM_CPU_IDLE --enable APM_DISPLAY_BLANK --enable APM_REAL_MODE_POWER_OFF --disable APM_RTC_IS_GMT --enable APM_ALLOW_INTS ;\
		( \
		 	echo 'CONFIG_SND_HDA_INTEL=y' ;\
		 	echo 'CONFIG_SND_HDA_POWER_SAVE_DEFAULT=10' \
	 	) >> .config \
	)
#		scripts/config --module SND ;\


## ,-----
## |	Build
## +-----

${CTI_LXHEADERS_BUILT}: ${CTI_LXHEADERS_CONFIGURED}
	( cd ${CTI_LXHEADERS_SRCROOT} || exit 1 ;\
	 	yes '' | make HOSTCC=/usr/bin/gcc oldconfig \
	)


## ,-----
## |	Install
## +-----

${CTI_LXHEADERS_INSTALLED}: ${CTI_LXHEADERS_BUILT}
	( cd ${CTI_LXHEADERS_SRCROOT} || exit 1 ;\
		make KBUILD_VERBOSE=1 headers_install INSTALL_HDR_PATH=${TCTREE}/usr/${TARGSPEC}/usr/ || exit 1 ;\
		mkdir -p ${TCTREE}/etc ;\
		cp .config ${CTI_LXHEADERS_INSTALLED} \
	)

.PHONY: cti-lxheaders
cti-lxheaders: ${CTI_LXHEADERS_INSTALLED}

.PHONY: CTI
CTI: ${CTI_LXHEADERS_INSTALLED}
