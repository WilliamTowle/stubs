# lx26bin v2.6.20.1		[ since v2.0.37pre10, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-lx26bin' -- cross-userland lx26bin"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_LX26BIN_SRC=${PKG_SRC}
CUI_LX26BIN_TEMP=cui-lx26bin-${PKG_VER}

FUDGE_LX26BIN_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_LX26BIN_INSTROOT=${EXTTEMP}/insttemp
FUDGE_LX26BIN_TARGET_MIN_SPEC=i386-xnc_k-linux-uclibc

## ,-----
## |	package extract
## +-----

CUI_LX26BIN_EXTRACTED=${EXTTEMP}/${CUI_LX26BIN_TEMP}/Makefile

.PHONY: cui-lx26bin-extracted
cui-lx26bin-extracted: ${CUI_LX26BIN_EXTRACTED}

${CUI_LX26BIN_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_LX26BIN_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_LX26BIN_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CUI_LX26BIN_TEMP}


## ,-----
## |	package configure
## +-----

CUI_LX26BIN_CONFIGURED=${EXTTEMP}/${CUI_LX26BIN_TEMP}/.config

.PHONY: cui-lx26bin-configured
cui-lx26bin-configured: cui-lx26bin-extracted ${CUI_LX26BIN_CONFIGURED}

# recent: cat arch/x86/configs/i386_defconfig
# older: cat arch/${TARGET_CPU}/defconfig

# 1. 'mrproper' is advised when switching architectures
${CUI_LX26BIN_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_LX26BIN_TEMP} || exit 1 ;\
		make ARCH=${TARGET_CPU} mrproper || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cp ${TC_ROOT}/etc/vmlinux-${PKG_VER}-Makefile Makefile || exit 1 ;\
		cp ${TC_ROOT}/etc/vmlinux-${PKG_VER}-config .config || exit 1 ;\
		yes '' | make oldconfig \
	)


## ,-----
## |	package build
## +-----

CUI_LX26BIN_BUILT=${EXTTEMP}/${CUI_LX26BIN_TEMP}/arch/${TARGET_CPU}/boot/bzImage

.PHONY: cui-lx26bin-built
cui-lx26bin-built: cui-lx26bin-configured ${CUI_LX26BIN_BUILT}

# v2.6 assumed
# [v2.6.x] 'prepare' builds autoconf.h

${CUI_LX26BIN_BUILT}:
	echo "*** $@ (BUILT) ***"
	mkdir -p ${FUDGE_LX26BIN_INSTROOT}/usr/include
	( cd ${EXTTEMP}/${CUI_LX26BIN_TEMP} || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} prepare || exit 1 ;\
		make bzImage || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----

CUI_LX26BIN_INSTALLED= ${TC_ROOT}/etc/bzImage-${PKG_VER}

.PHONY: cui-lx26bin-installed
cui-lx26bin-installed: cui-lx26bin-built ${CUI_LX26BIN_INSTALLED}

${CUI_LX26BIN_INSTALLED}:
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CUI_LX26BIN_TEMP} || exit 1 ;\
		mkdir -p ` dirname ${CUI_LX26BIN_INSTALLED} ` || exit 1 ;\
		cp ${CUI_LX26BIN_BUILT} ${CUI_LX26BIN_INSTALLED} \
	)


.PHONY: all-CUI
#all-CUI: cui-lx26bin-extracted
#all-CUI: cui-lx26bin-configured
#all-CUI: cui-lx26bin-built
all-CUI: cui-lx26bin-installed
