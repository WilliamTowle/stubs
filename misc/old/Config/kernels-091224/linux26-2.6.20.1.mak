# linux 2.6.20.1		[ EARLIEST v2.2.??, c.????-??-?? ]
# last mod WmT, 2009-12-24	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

NTI_LINUX_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}


## ,-----
## |	package extract
## +-----

NTI_LINUX_TEMP=nti-linux-${PKG_VER}
NTI_LINUX_EXTRACTED=${EXTTEMP}/${NTI_LINUX_TEMP}/Makefile

.PHONY: nti-linux-extracted
nti-linux-extracted: ${NTI_LINUX_EXTRACTED}

${NTI_LINUX_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${NTI_LINUX_SRC}
	[ ! -r ${EXTTEMP}/${NTI_LINUX_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_LINUX_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${NTI_LINUX_TEMP}


## ,-----
## |	package configure
## +-----

NTI_LINUX_CONFIGURED=${EXTTEMP}/${NTI_LINUX_TEMP}/.config

.PHONY: nti-linux-configured
nti-linux-configured: nti-linux-extracted ${NTI_LINUX_CONFIGURED}

# recent: cat arch/x86/configs/i386_defconfig
# older: cat arch/${TARGET_CPU}/defconfig

${NTI_LINUX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} mrproper || exit 1 ;\
		if [ -d arch/x86 ] ; then \
			cat arch/x86/configs/i386_defconfig ;\
		else \
			cat arch/${TARGET_CPU}/defconfig ;\
		fi	\
			| sed  '/CONFIG_MPENTIUM4=/    s/^/# /' \
			| sed   '/CONFIG_M.86/          s/^# //' \
			| sed   '/CONFIG_EMBEDDED/      s/^# //' \
			| sed   '/CONFIG_LOCALVERSION/  s/""/"mine"/' \
			| sed   '/CONFIG_IKCONFIG/      s/^/# /' \
                        | sed   '/CONFIG_MATH_EMULATION/ s/^# //' \
                        | sed   '/CONFIG_SOFTWARE_SUSPEND/ s/^/# /' \
                        | sed   '/CONFIG_BLK_DEV_LOOP/ s/^# //' \
                        | sed   '/CONFIG_BLK_DEV_RAM/ s/^# //' \
                        | sed   '/CONFIG_BLK_DEV_INITRD/ s/^# //' \
                        | sed   '/CONFIG_MINIX_FS/ s/^# //' \
                        | sed   '/^CONFIG.*not set/     s/ is not set/=y/ ; /^#.*=y/            s/=y/ is not set/ ' \
                        > .config ;\
		\
		echo "CONFIG_EXPERIMENTAL=y" >> .config ;\
		echo "CONFIG_MPENTIUMM=y" >> .config ;\
		echo "CONFIG_ATA=y" >> .config ;\
		echo "CONFIG_ATA_PIIX=y" >> .config ;\
		echo "CONFIG_SATA_AHCI=y" >> .config ;\
		echo "CONFIG_BLK_DEV_SD=y" >> .config ;\
		echo "CONFIG_HOTPLUG_PCI=y" >> .config ;\
		echo "CONFIG_PCIEPORTBUS=y" >> .config ;\
		echo "CONFIG_HOTPLUG_PCI_PCIE=y" >> .config ;\
		echo "CONFIG_USB=y" >> .config ;\
		echo 'CONFIG_BLK_DEV_LOOP=y' >> .config ;\
		echo "CONFIG_BLK_DEV_RAM=y" >> .config ;\
		echo "CONFIG_BLK_DEV_INITRD=y" >> .config ;\
		echo "CONFIG_PARIDE_PCD=y" >> .config ;\
		echo "CONFIG_PARIDE_PT=y" >> .config ;\
		echo "CONFIG_MINIX_FS=y" >> .config ;\
		echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config ;\
		echo "CONFIG_APM_DO_ENABLE=y" >> .config ;\
		echo "CONFIG_APM_CPU_IDLE=y" >> .config ;\
		echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config ;\
		echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config ;\
		echo "CONFIG_APM_ALLOW_INTS=y" >> .config ;\
		echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config ;\
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

NTI_LINUX_BUILT=${EXTTEMP}/${NTI_LINUX_TEMP}/arch/i386/boot/bzImage

.PHONY: nti-linux-built
nti-linux-built: nti-linux-configured ${NTI_LINUX_BUILT}

${NTI_LINUX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} prepare || exit 1 ;\
		make bzImage || exit 1 \
	)

## ,-----
## |	package install
## +-----

NTI_LINUX_INSTALLED= ${NTI_ROOT}/etc/bzImage-${PKG_VER}

.PHONY: nti-linux-installed
nti-linux-installed: nti-linux-built ${NTI_LINUX_INSTALLED}

${NTI_LINUX_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
		mkdir -p ` dirname ${NTI_LINUX_INSTALLED} ` || exit 1 ;\
		cp ${NTI_LINUX_BUILT} ${NTI_LINUX_INSTALLED} \
	)


.PHONY: all-NTI
all-NTI: nti-linux-installed
