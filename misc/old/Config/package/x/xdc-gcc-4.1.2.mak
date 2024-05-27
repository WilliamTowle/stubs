# xdc-gcc 4.1.2			[ since v2.7.2.3, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'kstc-gcc' -- cross-userland gcc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CUI_GCC_TEMP=cui-gcc-${PKG_VER}
CUI_GCC_EXTRACTED=${EXTTEMP}/${CUI_GCC_TEMP}/configure

FUDGE_GCC_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_GCC_INSTROOT=${EXTTEMP}/insttemp
FUDGE_GCC_HTC_GCC=i686-host-linux-uclibc-gcc

.PHONY: cui-gcc-extracted
cui-gcc-extracted: ${CUI_GCC_EXTRACTED}

${CUI_GCC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CUI_GCC_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_GCC_TEMP}
ifneq (${PKG_PATCHES},)
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc/*patch ; do \
			patch --batch -d gcc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
endif
	mv ${EXTTEMP}/gcc-${PKG_VER} ${EXTTEMP}/${CUI_GCC_TEMP}


## ,-----
## |	package configure
## +-----

CUI_GCC_CONFIGURED=${EXTTEMP}/${CUI_GCC_TEMP}/config.status

.PHONY: cui-gcc-configured
cui-gcc-configured: cui-gcc-extracted ${CUI_GCC_CONFIGURED}

${CUI_GCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_GCC_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-gcc \
		  CC_FOR_BUILD=${FUDGE_GCC_HTC_GCC} \
		  HOSTCC=${FUDGE_GCC_HTC_GCC} \
		  GCC_FOR_TARGET=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-gcc \
	  	  AR=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-ar \
	  	  AS=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-as \
	  	  LD=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-ld \
	  	  NM=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-nm \
	  	  RANLIB=${TC_ROOT}/usr/bin/${FUDGE_GCC_TARGET_SPEC}-ranlib \
	    	  CFLAGS=-O2 \
			./configure -v \
			  --prefix=/usr \
			  --build=${FUDGE_GCC_TARGET_SPEC} \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/gnu$$/uclibc/') \
			  --target=${FUDGE_GCC_TARGET_SPEC} \
			  ${HOST_GCC_ARCH_OPTS} \
			  --enable-clocale=uclibc \
			  --program-prefix='' \
			  --with-sysroot=/ \
			  --with-local-prefix=${XTC_ROOT}/usr \
			  --enable-languages=c \
			  --disable-__cxa_atexit \
			  --disable-nls \
			  --disable-libmudflap \
			  --disable-libssp \
			  --enable-shared \
			  --with-gnu-as \
			  --with-gnu-ld \
			  || exit 1 \
	)


## ,-----
## |	package build
## +-----

CUI_GCC_BUILT=${EXTTEMP}/${CUI_GCC_TEMP}/build-${TARGET_SPEC}/libiberty/libiberty.a

.PHONY: cui-gcc-built
cui-gcc-built: cui-gcc-configured ${CUI_GCC_BUILT}

# partial 'make' because we don't have libc, headers
${CUI_GCC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_GCC_TEMP} || exit 1 ;\
		make all-gcc prefix=/usr || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----

CUI_GCC_INSTALLED=${FUDGE_GCC_INSTROOT}/usr/bin/gcc

.PHONY: cui-gcc-installed
cui-gcc-installed: cui-gcc-built ${CUI_GCC_INSTALLED}

# partial 'install' because of partial 'make'                                   
${CUI_GCC_INSTALLED}:
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CUI_GCC_TEMP} || exit 1 ;\
		make install prefix=${FUDGE_GCC_INSTROOT}/usr || exit 1 \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-gcc-extracted
#all-CUI: cui-gcc-configured
#all-CUI: cui-gcc-built
all-CUI: cui-gcc-installed
