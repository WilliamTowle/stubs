# legtc-lx24config v2.4.37	[ since v2.0.37pre10, c.2002-10-14 ]
# last mod WmT, 2009-12-27	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LX24CONFIG_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}


## ,-----
## |	package extract
## +-----

CTI_LX24CONFIG_TEMP=cti-lx24config-${PKG_VER}
CTI_LX24CONFIG_EXTRACTED=${EXTTEMP}/${CTI_LX24CONFIG_TEMP}/Makefile

.PHONY: cti-lx24config-extracted
cti-lx24config-extracted: ${CTI_LX24CONFIG_EXTRACTED}

${CTI_LX24CONFIG_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LX24CONFIG_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LX24CONFIG_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LX24CONFIG_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LX24CONFIG_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LX24CONFIG_CONFIGURED=${EXTTEMP}/${CTI_LX24CONFIG_TEMP}/.config

.PHONY: cti-lx24config-configured
cti-lx24config-configured: cti-lx24config-extracted ${CTI_LX24CONFIG_CONFIGURED}

${CTI_LX24CONFIG_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LX24CONFIG_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make ${CTI_LX24CONFIG_ARCH_OPTS} mrproper symlinks || exit 1 ;\
		make include/linux/version.h || exit 1 ;\
		cat arch/${TARGET_CPU}/defconfig \
			| sed	'/CONFIG_MPENT/		s/^/# /' \
			| sed	'/CONFIG_M386/		s/^# //' \
			| sed	'/CONFIG_BLK_DEV_LOOP/ s/^# //' \
			| sed	'/CONFIG_BLK_DEV_RAM/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_INITRD/ s/^# //' \
			| sed	'/CONFIG_MINIX_FS/ s/^# //' \
			| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
			> .config ;\
		yes '' | make ${CTI_LX24CONFIG_ARCH_OPTS} oldconfig ;\
	)



## ,-----
## |	package build
## +-----

CTI_LX24CONFIG_BUILT=${EXTTEMP}/${CTI_LX24CONFIG_TEMP}/.depend

.PHONY: cti-lx24config-built
cti-lx24config-built: cti-lx24config-configured ${CTI_LX24CONFIG_BUILT}

${CTI_LX24CONFIG_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_LX24CONFIG_TEMP} || exit 1 ;\
		make ${CTI_LX24CONFIG_ARCH_OPTS} dep || exit 1 \
	)
#		make bzImage || exit 1 \


## ,-----
## |	package install
## +-----

CTI_LX24CONFIG_INSTALLED=${CTI_ROOT}/etc/config-linux-${PKG_VER}

.PHONY: cti-lx24config-installed
cti-lx24config-installed: cti-lx24config-built ${CTI_LX24CONFIG_INSTALLED}

${CTI_LX24CONFIG_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	mkdir -p ${CTI_ROOT}/etc/ || exit 1 ;\
	( cd ${EXTTEMP}/${CTI_LX24CONFIG_TEMP} || exit 1 ;\
		cp .config ${CTI_LX24CONFIG_INSTALLED} \
	)


.PHONY: all-CTI
#all-CTI: cti-lx24config-extracted
#all-CTI: cti-lx24config-configured
#all-CTI: cti-lx24config-built
all-CTI: cti-lx24config-installed
