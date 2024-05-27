# ultc-lx26src v2.6.28		[ since v2.0.37pre10, c.2002-10-14 ]
# last mod WmT, 2010-05-27	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LX26SRC_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}

ifeq (${TARGET_CPU},mipsel)
CTI_LX26SRC_ARCH_OPTS:=ARCH=mips
else
CTI_LX26SRC_ARCH_OPTS:=ARCH=${TARGET_CPU}
endif

#CTI_LX26SRC_ARCH_OPTS+= CROSS_COMPILE=${CTI_ROOT}/usr/bin/${TARGET_SPEC}-
##CTI_LX26SRC_ARCH_OPTS+= CONFIG_SHELL=${CONFIG_SHELL}


## ,-----
## |	package extract
## +-----

CTI_LX26SRC_TEMP=cti-lx26src-${PKG_VER}
CTI_LX26SRC_EXTRACTED=${EXTTEMP}/${CTI_LX26SRC_TEMP}/Makefile

.PHONY: cti-lx26src-extracted
cti-lx26src-extracted: ${CTI_LX26SRC_EXTRACTED}

${CTI_LX26SRC_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LX26SRC_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LX26SRC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LX26SRC_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LX26SRC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LX26SRC_CONFIGURED=${EXTTEMP}/${CTI_LX26SRC_TEMP}/.config

.PHONY: cti-lx26src-configured
cti-lx26src-configured: cti-lx26src-extracted ${CTI_LX26SRC_CONFIGURED}

${CTI_LX26SRC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LX26SRC_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/        s%g*cc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			> Makefile || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} mrproper || exit 1 ;\
		cp ${CTI_ROOT}/etc/config-linux26-${PKG_VER} .config || exit 1 ;\
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

CTI_LX26SRC_BUILT=${EXTTEMP}/${CTI_LX26SRC_TEMP}/include/asm

.PHONY: cti-lx26src-built
cti-lx26src-built: cti-lx26src-configured ${CTI_LX26SRC_BUILT}

${CTI_LX26SRC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_LX26SRC_TEMP} || exit 1 ;\
		make ${CTI_LX26SRC_ARCH_OPTS} prepare || exit 1 \
	)


## ,-----
## |	package install
## +-----

CTI_LX26SRC_INSTALLED=${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${PKG_VER}

.PHONY: cti-lx26src-installed
cti-lx26src-installed: cti-lx26src-built ${CTI_LX26SRC_INSTALLED}

${CTI_LX26SRC_INSTALLED}: ${CTI_ROOT}
	mkdir -p ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include
	mkdir -p ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${PKG_VER}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_LX26SRC_TEMP} || exit 1 ;\
		case ${PKG_VER}-${TARGET_CPU} in \
		2.6.20.1-*) \
			( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include/ && tar xf - ) ;\
		;; \
		2.6.28-i386) \
			( cd include/ >/dev/null && tar cvf - asm asm-x86 asm-generic linux ) | ( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/include/ && tar xf - ) ;\
		;; \
		*) \
			echo "Untested PKG_VER+TARGET_CPU ${PKG_VER} ${TARGET_CPU}" 2>&1 ;\
			exit 1 \
		;; \
		esac ;\
		( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src && ln -sf linux-${PKG_VER} linux ) || exit 1 ;\
		tar cvf - ./ | ( cd ${CTI_ROOT}/usr/${TARGET_SPEC}/usr/src/linux && tar xvf - ) \
	) || exit 1


.PHONY: all-CTI
all-CTI: cti-lx26src-installed
