# xdc-binutils v2.16.1		[ since v2.9.1, c.2002-10-31 ]
# last mod WmT, 2010-05-13	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'xdc-binutils' -- cross-userland binutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CUI_BINUTILS_TEMP=cui-binutils-${PKG_VER}
CUI_BINUTILS_EXTRACTED=${EXTTEMP}/${CUI_BINUTILS_TEMP}/configure

FUDGE_BINUTILS_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_BINUTILS_INSTROOT=${EXTTEMP}/insttemp
FUDGE_BINUTILS_HTC_GCC=i686-host-linux-uclibc-gcc

.PHONY: cui-binutils-extracted
cui-binutils-extracted: ${CUI_BINUTILS_EXTRACTED}

${CUI_BINUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} binutils-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CUI_BINUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_BINUTILS_TEMP}
ifneq (${PKG_PATCHES},)
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		if [ -d uclibc-patches ] ; then \
			for PF in uclibc-patches/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				patch --batch -d binutils-${PKG_VER} -Np1 < $${PF} ;\
				rm -f $${PF} ;\
			done ;\
		fi ;\
		if [ -d patch ] ; then \
			for PF in patch/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				sed '/+++ / { s%avr-%% ; s%binutils[^/]*/%% ; s%src/%% }' $${PF} | patch --batch -d binutils-${PKG_VER} -Np0 ;\
				rm -f $${PF} ;\
			done ;\
		fi \
	) || exit 1
endif
	mv ${EXTTEMP}/binutils-${PKG_VER} ${EXTTEMP}/${CUI_BINUTILS_TEMP}


## ,-----
## |	package configure
## +-----

CUI_BINUTILS_CONFIGURED=${EXTTEMP}/${CUI_BINUTILS_TEMP}/config.status

.PHONY: cui-binutils-configured
cui-binutils-configured: cui-binutils-extracted ${CUI_BINUTILS_CONFIGURED}

# binutils 2.16.1 lacks native support for '*-*-*-uclibc' target:
CUI_BINUTILS_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')
CUI_BINUTILS_TARGET_SPEC:=$(shell echo ${FUDGE_BINUTILS_TARGET_SPEC} | sed 's/uclibc$$/gnu/')

# 1. adjust target= to suit supported targets
# 2. --program-prefix ensures desired executable prefix
${CUI_BINUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_BINUTILS_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-gcc \
		AR=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-ar \
		  CC_FOR_BUILD=${TC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc \
		  HOSTCC=${TC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc \
	  	  AR=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-ar \
	  	  AS=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-as \
	  	  LD=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-ld \
	  	  NM=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-nm \
	  	  RANLIB=${TC_ROOT}/usr/bin/${FUDGE_BINUTILS_TARGET_SPEC}-ranlib \
	    	  CFLAGS=-O2 \
			./configure -v \
			  --prefix=/usr \
			  --build=${FUDGE_BINUTILS_TARGET_SPEC} \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/gnu$$/uclibc/') \
			  --target=${FUDGE_BINUTILS_TARGET_SPEC} \
			  --program-prefix='' \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)


## ,-----
## |	package build
## +-----

CUI_BINUTILS_BUILT=${EXTTEMP}/${CUI_BINUTILS_TEMP}/binutils/ar

.PHONY: cui-binutils-built
cui-binutils-built: cui-binutils-configured ${CUI_BINUTILS_BUILT}

${CUI_BINUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_BINUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

CUI_BINUTILS_INSTALLED=${FUDGE_BINUTILS_INSTROOT}/bin/ar

.PHONY: cui-binutils-installed
cui-binutils-installed: cui-binutils-built ${CUI_BINUTILS_INSTALLED}

${CUI_BINUTILS_INSTALLED}: ${CUI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CUI_BINUTILS_TEMP} || exit 1 ;\
		make install DESTDIR=${FUDGE_BINUTILS_INSTROOT} || exit 1 ;\
	)


.PHONY: all-CUI
#all-CUI: cui-binutils-extracted
#all-CUI: cui-binutils-configured
#all-CUI: cui-binutils-built
all-CUI: cui-binutils-installed
