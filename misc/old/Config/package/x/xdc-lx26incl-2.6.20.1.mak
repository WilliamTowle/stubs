# lx26incl v2.6.20.1		[ since v2.0.37pre10, c.????-??-?? ]
# last mod WmT, 2010-03-26	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-lx26incl' -- cross-userland lx26incl"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_LX26INCL_SRC=${PKG_SRC}
CUI_LX26INCL_TEMP=cui-lx26incl-${PKG_VER}

FUDGE_LX26INCL_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_LX26INCL_INSTROOT=${EXTTEMP}/insttemp
FUDGE_LX26INCL_TARGET_MIN_SPEC=i386-xnc_k-linux-uclibc

## ,-----
## |	package extract
## +-----

CUI_LX26INCL_EXTRACTED=${EXTTEMP}/${CUI_LX26INCL_TEMP}/Makefile

.PHONY: cui-lx26incl-extracted
cui-lx26incl-extracted: ${CUI_LX26INCL_EXTRACTED}

${CUI_LX26INCL_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_LX26INCL_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_LX26INCL_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CUI_LX26INCL_TEMP}


## ,-----
## |	package configure
## +-----

CUI_LX26INCL_CONFIGURED=${EXTTEMP}/${CUI_LX26INCL_TEMP}/.config

.PHONY: cui-lx26incl-configured
cui-lx26incl-configured: cui-lx26incl-extracted ${CUI_LX26INCL_CONFIGURED}

# recent: cat arch/x86/configs/i386_defconfig
# older: cat arch/${TARGET_CPU}/defconfig

# 1. 'mrproper' is advised when switching architectures
${CUI_LX26INCL_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_LX26INCL_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${FUDGE_LX26INCL_TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make mrproper || exit 1 ;\
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
		yes '' | make oldconfig ;\
		cp .config ${TC_ROOT}/etc/vmlinux-${PKG_VER}-config || exit 1 ;\
		cp Makefile ${TC_ROOT}/etc/vmlinux-${PKG_VER}-Makefile || exit 1 \
	) || exit 1


## ,-----
## |	package build
## +-----

CUI_LX26INCL_BUILT=${EXTTEMP}/${CUI_LX26INCL_TEMP}/include/asm

.PHONY: cui-lx26incl-built
cui-lx26incl-built: cui-lx26incl-configured ${CUI_LX26INCL_BUILT}

# [v2.6.x] 'prepare' builds autoconf.h

${CUI_LX26INCL_BUILT}:
	echo "*** $@ (BUILT) ***"
	mkdir -p ${FUDGE_LX26INCL_INSTROOT}/usr/include
	( cd ${EXTTEMP}/${CUI_LX26INCL_TEMP} || exit 1 ;\
		case "${PKG_VER}" in \
		2.0.*|2.2.*|2.4.*) \
			make dep || exit 1 \
		;; \
		2.6.*) \
			make prepare || exit 1 \
		;; \
		*) \
			echo "Build: Unexpected VERSION '${PKG_VER}'" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_LX26INCL_INSTALLED=${FUDGE_LX26INCL_INSTROOT}/usr/include/linux

.PHONY: cui-lx26incl-installed
cui-lx26incl-installed: cui-lx26incl-built ${CUI_LX26INCL_INSTALLED}

${CUI_LX26INCL_INSTALLED}:
	mkdir -p ${FUDGE_LX26INCL_INSTROOT}/usr/include
	( cd ${EXTTEMP}/${CUI_LX26INCL_TEMP} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FUDGE_LX26INCL_INSTROOT}/usr/include/ && tar xf - ) \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-lx26incl-extracted
#all-CUI: cui-lx26incl-configured
#all-CUI: cui-lx26incl-built
all-CUI: cui-lx26incl-installed
