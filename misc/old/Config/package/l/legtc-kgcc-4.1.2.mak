# legtc-kgcc v4.1.2		[ since v2.7.2.3, c.2002-10-14 ]
# last mod WmT, 2010-05-18	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'legtc-kgcc' -- cross kgcc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_KGCC_TEMP=cti-kgcc-${PKG_VER}
CTI_KGCC_EXTRACTED=${EXTTEMP}/${CTI_KGCC_TEMP}/configure

#CTI_KGCC_NATIVE_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')

.PHONY: cti-kgcc-extracted
cti-kgcc-extracted: ${CTI_KGCC_EXTRACTED}

${CTI_KGCC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CTI_KGCC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_KGCC_TEMP}
ifneq (${PKG_PATCHES},)
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP}/ || exit 1 ;\
		for PF in patch/*patch ; do \
			echo "*** PATCHING -- $${PF} ***" ;\
			grep '+++' $${PF} ;\
			patch --batch -d gcc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done ;\
		for PF in uclibc-patches/*patch ; do \
			echo "*** PATCHING -- $${PF} ***" ;\
			grep '+++' $${PF} ;\
			patch --batch -d gcc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	)
endif
	mv ${EXTTEMP}/gcc-${PKG_VER} ${EXTTEMP}/${CTI_KGCC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_KGCC_CONFIGURED=${EXTTEMP}/${CTI_KGCC_TEMP}/config.status

.PHONY: cti-kgcc-configured
cti-kgcc-configured: cti-kgcc-extracted ${CTI_KGCC_CONFIGURED}

${CTI_KGCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_KGCC_TEMP} || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	AR=$(shell echo ${NATIVE_GCC} | sed 's/g*cc$$/ar/') \
	    	  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${CTI_ROOT}/usr \
			  --target=${TARGET_MIN_SPEC} \
			  --enable-languages=c \
			  --disable-nls \
			  --disable-shared \
			  --disable-threads \
			  --without-headers \
			  --with-gnu-ld \
			  --with-gnu-as \
			  || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_KGCC_BUILT=${EXTTEMP}/${CTI_KGCC_TEMP}/build-${NATIVE_SPEC}/libiberty/libiberty.a

.PHONY: cti-kgcc-built
cti-kgcc-built: cti-kgcc-configured ${CTI_KGCC_BUILT}

# partial 'make' because we don't have libc, headers
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
${CTI_KGCC_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_KGCC_TEMP} || exit 1 ;\
	  	make install-gcc || exit 1 \
	)


.PHONY: all-CTI
all-CTI: cti-kgcc-installed
