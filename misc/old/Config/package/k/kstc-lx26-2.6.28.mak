# kstc-lx26incl 2.6.28		[ EARLIEST v2.0.37pre10, c.????-??-?? ]
# last mod WmT, 2010-04-30	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LINUX_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}


## ,-----
## |	package extract
## +-----

CTI_LINUX_TEMP=cti-linux-${PKG_VER}
CTI_LINUX_EXTRACTED=${EXTTEMP}/${CTI_LINUX_TEMP}/Makefile

.PHONY: cti-linux-extracted
cti-linux-extracted: ${CTI_LINUX_EXTRACTED}

${CTI_LINUX_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LINUX_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LINUX_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LINUX_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LINUX_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LINUX_CONFIGURED=${EXTTEMP}/${CTI_LINUX_TEMP}/.config

.PHONY: cti-linux-configured
cti-linux-configured: cti-linux-extracted ${CTI_LINUX_CONFIGURED}

# recent: cat arch/x86/configs/i386_defconfig
# older: cat arch/${TARGET_CPU}/defconfig

${CTI_LINUX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
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
		echo "CONFIG_ATL2=y" >> .config ;\
		\
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
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig ;\
		mkdir -p ${CTI_ROOT}/etc/ || exit 1 ;\
		cp .config ${CTI_ROOT}/etc/config-linux26-${PKG_VER} || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_LINUX_BUILT=${EXTTEMP}/${CTI_LINUX_TEMP}/arch/i386/boot/bzImage

.PHONY: cti-linux-built
cti-linux-built: cti-linux-configured ${CTI_LINUX_BUILT}

${CTI_LINUX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} prepare || exit 1 ;\
		make bzImage || exit 1 \
	)

## ,-----
## |	package install
## +-----

CTI_LINUX_INSTALLED= ${CTI_ROOT}/etc/bzImage-${PKG_VER}

.PHONY: cti-linux-installed
cti-linux-installed: cti-linux-built ${CTI_LINUX_INSTALLED}

${CTI_LINUX_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		mkdir -p ` dirname ${CTI_LINUX_INSTALLED} ` || exit 1 ;\
		cp ${CTI_LINUX_BUILT} ${CTI_LINUX_INSTALLED} \
	)


.PHONY: all-CTI
all-CTI: cti-linux-installed
