# legtc-lx24src v2.4.37		[ since v2.0.37pre10, c.2002-10-14 ]
# last mod WmT, 2010-05-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LX24SRC_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}

CTI_LX24SRC_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/uclibc$$/gnu/')

ifeq (${TARGET_CPU},mipsel)
CTI_LX24SRC_ARCH_OPTS:=ARCH=mips
else
CTI_LX24SRC_ARCH_OPTS:=ARCH=${TARGET_CPU}
endif

CTI_LX24SRC_ARCH_OPTS+= CROSS_COMPILE=${CTI_ROOT}/usr/bin/${TARGET_SPEC}-
#CTI_LX24SRC_ARCH_OPTS+= CONFIG_SHELL=${CONFIG_SHELL}

## ,-----
## |	package extract
## +-----

CTI_LX24SRC_TEMP=cti-lx24src-${PKG_VER}
CTI_LX24SRC_EXTRACTED=${EXTTEMP}/${CTI_LX24SRC_TEMP}/Makefile

.PHONY: cti-lx24src-extracted
cti-lx24src-extracted: ${CTI_LX24SRC_EXTRACTED}

${CTI_LX24SRC_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LX24SRC_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LX24SRC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LX24SRC_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LX24SRC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LX24SRC_CONFIGURED=${EXTTEMP}/${CTI_LX24SRC_TEMP}/.config

.PHONY: cti-lx24src-configured
cti-lx24src-configured: cti-lx24src-extracted ${CTI_LX24SRC_CONFIGURED}

${CTI_LX24SRC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LX24SRC_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
		make include/linux/version.h || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} dep || exit 1 ;\
		cp ${CTI_ROOT}/etc/config-linux-${PKG_VER} .config || exit 1 \
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

CTI_LX24SRC_BUILT=${EXTTEMP}/${CTI_LX24SRC_TEMP}/.depend

.PHONY: cti-lx24src-built
cti-lx24src-built: cti-lx24src-configured ${CTI_LX24SRC_BUILT}

${CTI_LX24SRC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_LX24SRC_TEMP} || exit 1 ;\
		make ${CTI_LX24SRC_ARCH_OPTS} dep || exit 1 \
	)
#		make bzImage || exit 1 \

## ,-----
## |	package install
## +-----

CTI_LX24SRC_INSTALLED=${CTI_ROOT}/usr/${CTI_LX24SRC_TARGET_SPEC}/usr/src/linux-${PKG_VER}

.PHONY: cti-lx24src-installed
cti-lx24src-installed: cti-lx24src-built ${CTI_LX24SRC_INSTALLED}

${CTI_LX24SRC_INSTALLED}: ${CTI_ROOT}
	mkdir -p ${CTI_ROOT}/usr/${CTI_LX24SRC_TARGET_SPEC}/usr/include
	mkdir -p ${CTI_ROOT}/usr/${CTI_LX24SRC_TARGET_SPEC}/usr/src/linux-${PKG_VER}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_LX24SRC_TEMP} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${CTI_ROOT}/usr/${CTI_LX24SRC_TARGET_SPEC}/usr/include/ && tar xf - ) ;\
		( cd ${CTI_ROOT}/usr/${CTI_LX24SRC_TARGET_SPEC}/usr/src && ln -sf linux-${PKG_VER} linux ) || exit 1 ;\
		tar cvf - ./ | ( cd ${CTI_ROOT}/usr/${CTI_LX24SRC_TARGET_SPEC}/usr/src/linux && tar xvf - ) \
	) || exit 1


.PHONY: all-CTI
#all-CTI: cti-lx24src-extracted
#all-CTI: cti-lx24src-configured
#all-CTI: cti-lx24src-built
all-CTI: cti-lx24src-installed
