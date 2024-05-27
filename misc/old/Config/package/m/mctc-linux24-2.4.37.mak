# mctc-linux24 2.4.37		[ EARLIEST v2.4.??, c.????-??-?? ]
# last mod WmT, 2009-12-27	[ (c) and GPLv2 1999-2009 ]

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

${CTI_LINUX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
		make include/linux/version.h || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} dep || exit 1 ;\
		cat arch/${TARGET_CPU}/defconfig \
			| sed	'/CONFIG_MPENT/		s/^/# /' \
			| sed	'/CONFIG_M386/		s/^# //' \
			| sed	'/CONFIG_BLK_DEV_LOOP/ s/^# //' \
			| sed	'/CONFIG_BLK_DEV_RAM/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_INITRD/ s/^# //' \
			| sed	'/CONFIG_MINIX_FS/ s/^# //' \
			| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
			> .config ;\
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

NTI_LINUX_BUILT=${EXTTEMP}/${NTI_LINUX_TEMP}/src/diff

.PHONY: nti-linux-built
nti-linux-built: nti-linux-configured ${NTI_LINUX_BUILT}

${NTI_LINUX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
		make bzImage || exit 1 \
	)

## ,-----
## |	package install
## +-----

#NTI_LINUX_INSTALLED=${NTI_ROOT}/usr/bin/diff
#
#.PHONY: nti-linux-installed
#nti-linux-installed: nti-linux-built ${NTI_LINUX_INSTALLED}
#
#${NTI_LINUX_INSTALLED}: ${NTI_ROOT}
#	echo "*** $@ (INSTALLED) ***"
#	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
#		make install \
#	)


.PHONY: all-CTI
#all-CTI: cti-linux-extracted
all-CTI: cti-linux-configured
#all-CTI: cti-linux-built
#all-CTI: cti-linux-installed
