# kstc-kgcc v2.95.3-2		[ since v2.7.2.3, c.????-??-?? ]
# last mod WmT, 2010-01-27	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'kstc-kgcc' -- cross kgcc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_KGCC_TEMP=cti-kgcc-${PKG_VER}
CTI_KGCC_EXTRACTED=${EXTTEMP}/${CTI_KGCC_TEMP}/configure

.PHONY: cti-kgcc-extracted
cti-kgcc-extracted: ${CTI_KGCC_EXTRACTED}

${CTI_KGCC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
ifeq (${PKG_PATCHES},)
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-2.95.3 ${PKG_SRC}
else
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-2.95.3 ${PKG_SRC} ${PKG_PATCHES}
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
                for PF in ${PKG_PATCHES} ; do \
                        patch --batch -d gcc-2.95.3 -Np1 < gcc-2.95.3/`basename $${PF}` ;\
                        rm -f gcc-2.95.3/`basename $${PF}` ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${CTI_KGCC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_KGCC_TEMP}
	mv ${EXTTEMP}/gcc-2.95.3 ${EXTTEMP}/${CTI_KGCC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_KGCC_CONFIGURED=${EXTTEMP}/${CTI_KGCC_TEMP}/config.status

.PHONY: cti-kgcc-configured
cti-kgcc-configured: cti-kgcc-extracted ${CTI_KGCC_CONFIGURED}

# gcc v2.95.3 lacks native support for '*-*-*-uclibc' target:         
CTI_KGCC_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')
CTI_KGCC_TARGET_SPEC:=$(shell echo ${TARGET_MIN_SPEC} | sed 's/uclibc$$/gnu/')

# 1. adjust target= to suit supported targets
# 2. --program-transform-cross-name ensures desired executable prefix
${CTI_KGCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_KGCC_TEMP} || exit 1 ;\
		CC=${NATIVE_SPEC}-gcc \
		  AR=${NATIVE_SPEC}-ar \
		  CFLAGS='-O2' \
		    ./configure -v \
			--prefix=${CTI_ROOT}/usr \
			--host=${CTI_KGCC_PROVIDER_SPEC} \
			--build=${CTI_KGCC_PROVIDER_SPEC} \
			--target=${CTI_KGCC_TARGET_SPEC} \
			--program-transform-cross-name='s,^,'${TARGET_MIN_SPEC}'-,' \
			--without-headers \
			--with-newlib \
			--enable-languages=c \
			--disable-nls \
			--enable-shared \
			|| exit 1 ;\
		[ -r gcc/Makefile.OLD ] || mv gcc/Makefile gcc/Makefile.OLD || exit 1 ;\
		cat gcc/Makefile.OLD \
			| sed '/^GCC_CROSS_NAME/ s/`.*`/'${TARGET_MIN_SPEC}'-gcc/' \
			> gcc/Makefile || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_KGCC_BUILT=${EXTTEMP}/${CTI_KGCC_TEMP}/build-${TARGET_SPEC}/libiberty/libiberty.a

.PHONY: cti-kgcc-built
cti-kgcc-built: cti-kgcc-configured ${CTI_KGCC_BUILT}

# partial 'make' because we don't have libc, headers yet (libiberty fails)
${CTI_KGCC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_KGCC_TEMP} || exit 1 ;\
		make all-gcc || exit 1 \
	)


## ,-----
## |	package install
## +-----

CTI_KGCC_INSTALLED=${CTI_ROOT}/usr/bin/${TARGET_MIN_SPEC}-gcc

.PHONY: cti-kgcc-installed
cti-kgcc-installed: cti-kgcc-built ${CTI_KGCC_INSTALLED}

# partial 'install' because of partial 'make'
# no need to adjust 'specs' file for same reason
# gcc v2.95.3: --program-transform-cross-name b0rked?
${CTI_KGCC_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_KGCC_TEMP} || exit 1 ;\
		GCC_CROSS_NAME=${TARGET_MIN_SPEC}'-gcc' make install-gcc || exit 1 \
	)


.PHONY: all-CTI
all-CTI: cti-kgcc-installed
