# legtc-lx26incl v2.6.20.1	[ since v2.0.37pre10, c.2002-10-14 ]
# last mod WmT, 2010-05-17	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LX26INCL_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}

ifeq (${TARGET_CPU},mipsel)
CTI_LX26INCL_ARCH_OPTS:=ARCH=mips
else
CTI_LX26INCL_ARCH_OPTS:=ARCH=${TARGET_CPU}
endif

#CTI_LX26INCL_ARCH_OPTS+= CROSS_COMPILE=${CTI_ROOT}/usr/bin/${TARGET_SPEC}-
##CTI_LX26INCL_ARCH_OPTS+= CONFIG_SHELL=${CONFIG_SHELL}

## ,-----
## |	package extract
## +-----

CTI_LX26INCL_TEMP=cti-lx26incl-${PKG_VER}
CTI_LX26INCL_EXTRACTED=${EXTTEMP}/${CTI_LX26INCL_TEMP}/Makefile

.PHONY: cti-lx26incl-extracted
cti-lx26incl-extracted: ${CTI_LX26INCL_EXTRACTED}

${CTI_LX26INCL_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LX26INCL_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LX26INCL_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LX26INCL_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LX26INCL_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LX26INCL_CONFIGURED=${EXTTEMP}/${CTI_LX26INCL_TEMP}/.config

.PHONY: cti-lx26incl-configured
cti-lx26incl-configured: cti-lx26incl-extracted ${CTI_LX26INCL_CONFIGURED}

${CTI_LX26INCL_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LX26INCL_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} mrproper || exit 1 ;\
		cp ${CTI_ROOT}/etc/config-linux-${PKG_VER} .config || exit 1 \
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

CTI_LX26INCL_BUILT=${EXTTEMP}/${CTI_LX26INCL_TEMP}/include/config

.PHONY: cti-lx26incl-built
cti-lx26incl-built: cti-lx26incl-configured ${CTI_LX26INCL_BUILT}

${CTI_LX26INCL_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_LX26INCL_TEMP} || exit 1 ;\
		make ${CTI_LX26INCL_ARCH_OPTS} prepare || exit 1 \
	)
#		make bzImage || exit 1 \

## ,-----
## |	package install
## +-----

CTI_LX26INCL_INSTALLED=${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include/asm

.PHONY: cti-lx26incl-installed
cti-lx26incl-installed: cti-lx26incl-built ${CTI_LX26INCL_INSTALLED}

${CTI_LX26INCL_INSTALLED}: ${CTI_ROOT}
	mkdir -p ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include
	mkdir -p ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${PKG_VER}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_LX26INCL_TEMP} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include/ && tar xf - ) ;\
		( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src && ln -sf linux-${PKG_VER} linux ) || exit 1 ;\
		tar cvf - ./ | ( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src/linux && tar xvf - ) \
	) || exit 1



.PHONY: all-CTI
#all-CTI: cti-lx26incl-extracted
#all-CTI: cti-lx26incl-configured
#all-CTI: cti-lx26incl-built
all-CTI: cti-lx26incl-installed
