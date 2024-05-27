# ultc-gcc v2.95.3-2		[ since v2.7.2.3, c.????-??-?? ]
# last mod WmT, 2010-04-28	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'ultc-gcc' -- cross kgcc"

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
	[ ! -r ${EXTTEMP}/${CTI_GCC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_GCC_TEMP}
	mv ${EXTTEMP}/gcc-2.95.3 ${EXTTEMP}/${CTI_GCC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_GCC_CONFIGURED=${EXTTEMP}/${CTI_GCC_TEMP}/config.status

.PHONY: cti-gcc-configured
cti-gcc-configured: cti-gcc-extracted ${CTI_GCC_CONFIGURED}

# gcc v2.95.3 lacks native support for '*-*-*-uclibc' target:         
CTI_GCC_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')
CTI_GCC_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/uclibc$$/gnu/')

${CTI_GCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_GCC_TEMP} || exit 1 ;\
		CC=${NATIVE_SPEC}-gcc \
		  AR=${NATIVE_SPEC}-ar \
		  CFLAGS='-O2' \
		    ./configure -v \
			--prefix=${CTI_ROOT}/usr \
			--host=${CTI_GCC_PROVIDER_SPEC} \
			--build=${CTI_GCC_PROVIDER_SPEC} \
			--target=${CTI_GCC_TARGET_SPEC} \
			--program-transform-cross-name='s,^,'${TARGET_SPEC}'-,' \
			  --with-headers=${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/include' \
			  --with-libs=${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/lib' \
			--enable-languages=c \
			--disable-nls \
			--enable-shared \
			|| exit 1 ;\
		[ -r gcc/Makefile.OLD ] || mv gcc/Makefile gcc/Makefile.OLD || exit 1 ;\
		cat gcc/Makefile.OLD \
			| sed '/^GCC_CROSS_NAME/ s/`.*`/'${TARGET_SPEC}'-gcc/' \
			> gcc/Makefile || exit 1 \
	)
#		CC=${NATIVE_SPEC}-gcc \
#		    ./configure -v \
#			--prefix=${CTI_ROOT}/usr \
#			--target=${CTI_GCC_TARGET_SPEC} \
#			  --enable-languages=c \
#			  --disable-nls \
#			  --enable-shared \
#			  --with-headers=${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/include' \
#			  --with-libs=${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/lib' \
#			|| exit 1 ;\
#		[ -r gcc/Makefile.OLD ] || mv gcc/Makefile gcc/Makefile.OLD || exit 1 ;\
#		cat gcc/Makefile.OLD \
#			| sed '/^GCC_CROSS_NAME/ s/`.*`/'${TARGET_SPEC}'-gcc/' \
#			> gcc/Makefile || exit 1 \
#	)
##			--host=${CTI_GCC_PROVIDER_SPEC} \
##			--build=${CTI_GCC_PROVIDER_SPEC} \
###			--program-transform-cross-name='s,^,'${TARGET_SPEC}'-,' \
###			--without-headers \
###			--with-newlib \
###			--enable-languages=c \
###			--disable-nls \
###			--enable-shared \
###			|| exit 1 ;\
###		[ -r gcc/Makefile.OLD ] || mv gcc/Makefile gcc/Makefile.OLD || exit 1 ;\
###		cat gcc/Makefile.OLD \
###			| sed '/^GCC_CROSS_NAME/ s/`.*`/'${TARGET_SPEC}'-gcc/' \
###			> gcc/Makefile || exit 1 \
###	)


## ,-----
## |	package build
## +-----

CTI_GCC_BUILT=${EXTTEMP}/${CTI_GCC_TEMP}/libiberty/libiberty.a

.PHONY: cti-gcc-built
cti-gcc-built: cti-gcc-configured ${CTI_GCC_BUILT}

${CTI_GCC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_GCC_TEMP} || exit 1 ;\
		make all-gcc || exit 1 \
	)
#		make || exit 1 \


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
		GCC_CROSS_NAME=${TARGET_SPEC}'-gcc' make install-gcc || exit 1 ;\
		case ${TARGET_SPEC} in \
		*-uclibc) \
			cat gcc/specs \
				| sed   '/dynamic-linker:/ s/ld-linux.so.2/ld-uClibc.so.0/ ' \
				> ${CTI_ROOT}/usr/lib/gcc-lib/${CTI_GCC_TARGET_SPEC}/2.95.3/specs \
				|| exit 1 \
		;; \
		esac \
	)


.PHONY: all-CTI
all-CTI: cti-gcc-installed
