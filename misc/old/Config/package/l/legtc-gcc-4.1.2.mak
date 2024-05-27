# legtc-gcc v4.1.2		[ since v2.7.2.3, c.2002-10-14 ]
# last mod WmT, 2010-04-04	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'legtc-gcc' -- cross gcc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_GCC_TEMP=cti-gcc-${PKG_VER}
CTI_GCC_EXTRACTED=${EXTTEMP}/${CTI_GCC_TEMP}/configure

.PHONY: cti-gcc-extracted
cti-gcc-extracted: ${CTI_GCC_EXTRACTED}

${CTI_GCC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CTI_GCC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_GCC_TEMP}
ifneq (${PKG_PATCHES},)
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
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
	mv ${EXTTEMP}/gcc-${PKG_VER} ${EXTTEMP}/${CTI_GCC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_GCC_CONFIGURED=${EXTTEMP}/${CTI_GCC_TEMP}/config.status

.PHONY: cti-gcc-configured
cti-gcc-configured: cti-gcc-extracted ${CTI_GCC_CONFIGURED}

## gcc v2.95.3 lacks native support for '*-*-*-uclibc' target:         
#CTI_GCC_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')
#CTI_GCC_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/uclibc$$/gnu/')

${CTI_GCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_GCC_TEMP} || exit 1 ;\
		CC=${NATIVE_SPEC}-gcc \
		  AR=${NATIVE_SPEC}-ar \
		  CFLAGS='-O2' \
		    ./configure -v \
			--prefix=${CTI_ROOT}/usr \
			--host=${NATIVE_SPEC} \
			--build=${NATIVE_SPEC} \
			--target=${TARGET_SPEC} \
			--with-sysroot=${CTI_ROOT}/usr/${TARGET_SPEC} \
		        --with-local-prefix=${CTI_ROOT}/usr \
	        	--enable-languages=c \
	        	--enable-clocale=uclibc \
	        	--disable-__cxa_atexit \
	        	--disable-nls \
	        	--disable-libmudflap \
	        	--disable-libssp \
	        	--enable-shared \
	        	|| exit 1 \
	) || exit 1


## ,-----
## |	package build
## +-----

CTI_GCC_BUILT=${EXTTEMP}/${CTI_GCC_TEMP}/libiberty/libiberty.a

.PHONY: cti-gcc-built
cti-gcc-built: cti-gcc-configured ${CTI_GCC_BUILT}

${CTI_GCC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_GCC_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

CTI_GCC_INSTALLED=${CTI_ROOT}/usr/bin/${TARGET_SPEC}-gcc

.PHONY: cti-gcc-installed
cti-gcc-installed: cti-gcc-built ${CTI_GCC_INSTALLED}

# partial 'install' because of partial 'make'
# no need to adjust 'specs' file for same reason
# gcc v2.95.3: --program-transform-cross-name b0rked?
${CTI_GCC_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_GCC_TEMP} || exit 1 ;\
		make install || exit 1 ;\
	)


.PHONY: all-CTI
all-CTI: cti-gcc-installed
