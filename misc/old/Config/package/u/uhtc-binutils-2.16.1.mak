# uhtc-binutils v2.16.1		[ since v2.9.1, c.2002-10-14 ]
# last mod WmT, 2010-06-02	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'uhtc-binutils' -- host binutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_BINUTILS_TEMP=nti-binutils-${PKG_VER}
NTI_BINUTILS_EXTRACTED=${EXTTEMP}/${NTI_BINUTILS_TEMP}/configure

.PHONY: nti-binutils-extracted
nti-binutils-extracted: ${NTI_BINUTILS_EXTRACTED}

${NTI_BINUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} binutils-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
ifneq (${PKG_PATCHES},)
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc-patches/*patch ; do \
			echo "*** PATCHING -- $${PF} ***" ;\
			grep '+++' $${PF} ;\
			patch --batch -d binutils-${PKG_VER} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done ;\
		for PF in patch/*patch ; do \
			echo "*** PATCHING -- $${PF} ***" ;\
			grep '+++' $${PF} ;\
			sed '/+++ / { s%avr-%% ; s%binutils[^/]*/%% ; s%src/%% }' $${PF} | patch --batch -d binutils-${PKG_VER} -Np0 ;\
			rm -f $${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${NTI_BINUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_BINUTILS_TEMP}
	mv ${EXTTEMP}/binutils-${PKG_VER} ${EXTTEMP}/${NTI_BINUTILS_TEMP}


## ,-----
## |	package configure
## +-----

NTI_BINUTILS_CONFIGURED=${EXTTEMP}/${NTI_BINUTILS_TEMP}/config.status

.PHONY: nti-binutils-configured
nti-binutils-configured: nti-binutils-extracted ${NTI_BINUTILS_CONFIGURED}

# binutils 2.16.1 lacks native support for '*-*-*-uclibc' target:               
NTI_BINUTILS_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')

# 1. adjust target= to suit supported targets
# 2. --program-prefix ensures desired executable prefix
${NTI_BINUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_BINUTILS_TEMP} || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	AR=$(shell echo ${NATIVE_GCC} | sed 's/g*cc$$/ar/') \
	    	  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${NTI_ROOT}/usr \
			  --host=${NTI_BINUTILS_PROVIDER_SPEC} \
			  --build=${NTI_BINUTILS_PROVIDER_SPEC} \
			  --target=${NTI_BINUTILS_PROVIDER_SPEC} \
			  --program-prefix=${NATIVE_SPEC}- \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)


## ,-----
## |	package build
## +-----

NTI_BINUTILS_BUILT=${EXTTEMP}/${NTI_BINUTILS_TEMP}/binutils/ar

.PHONY: nti-binutils-built
nti-binutils-built: nti-binutils-configured ${NTI_BINUTILS_BUILT}

${NTI_BINUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_BINUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

NTI_BINUTILS_INSTALLED=${NTI_ROOT}/usr/${NTI_BINUTILS_PROVIDER_SPEC}/bin/ar

.PHONY: nti-binutils-installed
nti-binutils-installed: nti-binutils-built ${NTI_BINUTILS_INSTALLED}

${NTI_BINUTILS_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_BINUTILS_TEMP} || exit 1 ;\
	  	make install || exit 1 \
	)


.PHONY: all-NTI
all-NTI: nti-binutils-installed
