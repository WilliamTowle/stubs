# kstc-kbinutils v2.17		[ since v2.9.1, c.2002-10-14 ]
# last mod WmT, 2010-05-24	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'kstc-kbinutils' -- kernel-space binutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_KBINUTILS_TEMP=cti-kbinutils-${PKG_VER}
CTI_KBINUTILS_EXTRACTED=${EXTTEMP}/${CTI_KBINUTILS_TEMP}/configure

.PHONY: cti-kbinutils-extracted
cti-kbinutils-extracted: ${CTI_KBINUTILS_EXTRACTED}

${CTI_KBINUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} binutils-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CTI_KBINUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_KBINUTILS_TEMP}
# only 'geex' does patching(?!!)
#ifneq (${PKG_PATCHES},)
#	echo "*** ${PKG_NAME}: PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in uclibc-patches/*patch ; do \
#			echo "*** PATCHING -- $${PF} ***" ;\
#			grep '+++' $${PF} ;\
#			patch --batch -d binutils-${PKG_VER} -Np1 < $${PF} ;\
#			rm -f $${PF} ;\
#		done ;\
#		for PF in patch/*patch ; do \
#			echo "*** PATCHING -- $${PF} ***" ;\
#			grep '+++' $${PF} ;\
#			sed '/+++ binutils/ { s%binutils-[^/]*/%% ; s%binutils/ld%ld% }' $${PF} | patch --batch -d binutils-${PKG_VER} -Np0 ;\
#			rm -f $${PF} ;\
#		done ;\
#	)
#endif
	mv ${EXTTEMP}/binutils-${PKG_VER} ${EXTTEMP}/${CTI_KBINUTILS_TEMP}



## ,-----
## |	package configure
## +-----

CTI_KBINUTILS_CONFIGURED=${EXTTEMP}/${CTI_KBINUTILS_TEMP}/config.status

.PHONY: cti-kbinutils-configured
cti-kbinutils-configured: cti-kbinutils-extracted ${CTI_KBINUTILS_CONFIGURED}

# 1. adjust target= to suit supported targets
# 2. --program-prefix ensures desired executable prefix
${CTI_KBINUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_KBINUTILS_TEMP} || exit 1 ;\
	  	CC=${NATIVE_SPEC}-gcc \
	  	AR=${NATIVE_SPEC}-ar \
	    	  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${CTI_ROOT}'/usr' \
			  --host=${NATIVE_SPEC} \
			  --build=${NATIVE_SPEC} \
			  --target=${TARGET_SPEC} \
			  --with-sysroot=${CTI_ROOT}'/usr/'${TARGET_SPEC} \
			  --program-prefix=${TARGET_SPEC}- \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_KBINUTILS_BUILT=${EXTTEMP}/${CTI_KBINUTILS_TEMP}/binutils/ar

.PHONY: cti-kbinutils-built
cti-kbinutils-built: cti-kbinutils-configured ${CTI_KBINUTILS_BUILT}

${CTI_KBINUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_KBINUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

CTI_KBINUTILS_INSTALLED=${CTI_ROOT}/usr/${TARGET_SPEC}/bin/ar

.PHONY: cti-kbinutils-installed
cti-kbinutils-installed: cti-kbinutils-built ${CTI_KBINUTILS_INSTALLED}

${CTI_KBINUTILS_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_KBINUTILS_TEMP} || exit 1 ;\
		mkdir -p ${CTI_ROOT}/usr/${TARGET_MIN_SPEC}/bin || exit 1 ;\
	  	make install || exit 1 ;\
	  	for EXE in addr2line ar as c++filt ld nm \
	  		objcopy objdump ranlib readelf size \
	  		strings strip ; do \
	  		( cd ${CTI_ROOT}/usr/bin && ln -sf ${TARGET_SPEC}-$${EXE} ${TARGET_MIN_SPEC}-$${EXE} ) || exit 1 ;\
	  		( cd ${CTI_ROOT}/usr/${TARGET_MIN_SPEC}/bin && ln -sf ../../${TARGET_SPEC}/bin/$${EXE} ./ ) || exit 1 ;\
	  	done \
	)


.PHONY: all-CTI
all-CTI: cti-kbinutils-installed
