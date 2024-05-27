# legtc-binutils v2.16.1	[ since v2.9.1, c.2002-10-14 ]
# last mod WmT, 2010-05-12	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'legtc-binutils' -- kernel-space binutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_BINUTILS_TEMP=cti-binutils-${PKG_VER}
CTI_BINUTILS_EXTRACTED=${EXTTEMP}/${CTI_BINUTILS_TEMP}/configure

.PHONY: cti-binutils-extracted
cti-binutils-extracted: ${CTI_BINUTILS_EXTRACTED}

${CTI_BINUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} binutils-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CTI_BINUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_BINUTILS_TEMP}
	mv ${EXTTEMP}/binutils-${PKG_VER} ${EXTTEMP}/${CTI_BINUTILS_TEMP}


## ,-----
## |	package configure
## +-----

CTI_BINUTILS_CONFIGURED=${EXTTEMP}/${CTI_BINUTILS_TEMP}/config.status

.PHONY: cti-binutils-configured
cti-binutils-configured: cti-binutils-extracted ${CTI_BINUTILS_CONFIGURED}

# binutils 2.16.1 lacks native support for '*-*-*-uclibc' target:
CTI_BINUTILS_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')
CTI_BINUTILS_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/uclibc$$/gnu/')

# 1. adjust target= to suit supported targets
# 2. --program-prefix ensures desired executable prefix
${CTI_BINUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_BINUTILS_TEMP} || exit 1 ;\
	  	CC=${NATIVE_SPEC}-gcc \
	  	AR=${NATIVE_SPEC}-ar \
	    	  CFLAGS='-O2' \
			./configure -v \
			  --prefix=${CTI_ROOT}'/usr' \
			  --build=${CTI_BINUTILS_PROVIDER_SPEC} \
			  --host=${CTI_BINUTILS_PROVIDER_SPEC} \
			  --target=${CTI_BINUTILS_TARGET_SPEC} \
			  --with-sysroot=${CTI_ROOT}'/usr/'${CTI_BINUTILS_TARGET_SPEC} \
			  --program-prefix=${TARGET_SPEC}- \
			  --enable-shared \
			  --disable-nls \
			  || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_BINUTILS_BUILT=${EXTTEMP}/${CTI_BINUTILS_TEMP}/binutils/ar

.PHONY: cti-binutils-built
cti-binutils-built: cti-binutils-configured ${CTI_BINUTILS_BUILT}

${CTI_BINUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_BINUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

CTI_BINUTILS_INSTALLED=${CTI_ROOT}/usr/${CTI_BINUTILS_TARGET_SPEC}/bin/ar

.PHONY: cti-binutils-installed
cti-binutils-installed: cti-binutils-built ${CTI_BINUTILS_INSTALLED}

${CTI_BINUTILS_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_BINUTILS_TEMP} || exit 1 ;\
	  	make install || exit 1 \
	)


.PHONY: all-CTI
all-CTI: cti-binutils-installed
