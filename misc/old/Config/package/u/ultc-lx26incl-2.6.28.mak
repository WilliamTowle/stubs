# ultc-lx26incl 2.6.28		[ since v2.0.37pre10, c.2002-10-14 ]
# last mod WmT, 2010-05-27	[ (c) and GPLv2 1999-2009 ]

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

CTI_LINUX_TEMP=cti-lx26incl-${PKG_VER}
CTI_LINUX_EXTRACTED=${EXTTEMP}/${CTI_LINUX_TEMP}/Makefile

.PHONY: cti-lx26incl-extracted
cti-lx26incl-extracted: ${CTI_LINUX_EXTRACTED}

${CTI_LINUX_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LINUX_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LINUX_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LINUX_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LINUX_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LINUX_CONFIGURED=${EXTTEMP}/${CTI_LINUX_TEMP}/.config

.PHONY: cti-lx26incl-configured
cti-lx26incl-configured: cti-lx26incl-extracted ${CTI_LINUX_CONFIGURED}

# recent: cat arch/x86/configs/i386_defconfig
# older: cat arch/${TARGET_CPU}/defconfig

# 1. 'mrproper' is advised when switching architectures
${CTI_LINUX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} mrproper || exit 1 ;\
		cp ${CTI_ROOT}/etc/config-linux26-${PKG_VER} .config || exit 1 \
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

CTI_LINUX_BUILT=${EXTTEMP}/${CTI_LINUX_TEMP}/arch/i386/boot/bzImage

.PHONY: cti-lx26incl-built
cti-lx26incl-built: cti-lx26incl-configured ${CTI_LINUX_BUILT}

# 'prepare' builds autoconf.h et al

${CTI_LINUX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} prepare || exit 1 ;\
	)

## ,-----
## |	package install
## +-----

CTI_LINUX_INSTALLED= ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include

.PHONY: cti-lx26incl-installed
cti-lx26incl-installed: cti-lx26incl-built ${CTI_LINUX_INSTALLED}

${CTI_LINUX_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		mkdir -p ${CTI_ROOT}/etc/ || exit 1 ;\
		cp .config ${CTI_ROOT}/etc/config-linux26-${PKG_VER} || exit 1 ;\
		make ARCH=${TARGET_CPU} INSTALL_HDR_PATH=${CTI_ROOT}/usr/${TARGET_SPEC}/usr headers_install || exit 1 \
	)


.PHONY: all-CTI
#all-CTI: cti-lx26incl-extracted
#all-CTI: cti-lx26incl-configured
#all-CTI: cti-lx26incl-built
all-CTI: cti-lx26incl-installed
