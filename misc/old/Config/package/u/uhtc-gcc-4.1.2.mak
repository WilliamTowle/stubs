# shtc-gcc v4.1.2		[ since v2.7.2.3, c.????-??-?? ]
# last mod WmT, 2009-12-25	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'shtc-gcc' -- host gcc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_GCC_TEMP=nti-gcc-${PKG_VER}
NTI_GCC_EXTRACTED=${EXTTEMP}/${NTI_GCC_TEMP}/configure

.PHONY: nti-gcc-extracted
nti-gcc-extracted: ${NTI_GCC_EXTRACTED}

${NTI_GCC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
ifeq (${PKG_PATCHES},)
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-${PKG_VER} ${PKG_SRC}
else
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
                for PF in uclibc/*patch ; do \
                        patch --batch -d gcc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f ${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${NTI_GCC_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_GCC_TEMP}
	mv ${EXTTEMP}/gcc-${PKG_VER} ${EXTTEMP}/${NTI_GCC_TEMP}


## ,-----
## |	package configure
## +-----

NTI_GCC_CONFIGURED=${EXTTEMP}/${NTI_GCC_TEMP}/config.status

.PHONY: nti-gcc-configured
nti-gcc-configured: nti-gcc-extracted ${NTI_GCC_CONFIGURED}

${NTI_GCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_GCC_TEMP} || exit 1 ;\
	  CC=${NATIVE_CC} \
		AR=$(shell echo ${NATIVE_CC} | sed 's/g*cc$$/ar/') \
		CFLAGS='-O2' \
		  ./configure -v \
			--prefix=${NTI_ROOT}/usr \
                        --host=${NATIVE_SPEC} \
                        --target=${NATIVE_SPEC} \
                        --with-sysroot=/ \
                        --with-local-prefix=${NTI_ROOT}/usr \
                        --enable-languages=c \
                        --disable-nls \
                        --disable-libmudflap \
                        --disable-libssp \
                        --enable-shared \
			|| exit 1 \
	)


## ,-----
## |	package build
## +-----

NTI_GCC_BUILT=${EXTTEMP}/${NTI_GCC_TEMP}/host-${NATIVE_SPEC}/gcc/xgcc

.PHONY: nti-gcc-built
nti-gcc-built: nti-gcc-configured ${NTI_GCC_BUILT}

# full 'make' because we have libc, headers natively
${NTI_GCC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_GCC_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

NTI_GCC_INSTALLED=${NTI_ROOT}/usr/bin/${NATIVE_SPEC}-gcc

.PHONY: nti-gcc-installed
nti-gcc-installed: nti-gcc-built ${NTI_GCC_INSTALLED}

${NTI_GCC_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_GCC_TEMP} || exit 1 ;\
	  	make install || exit 1 \
	)


## host gcc 4.1.2
## last mod WmT, 2009-06-08	[ (c) and GPLv2 1999-2009 ]
#
#USAGE_RULES+= "'nis-host-gcc' -- host-toolchain gcc"
#
#
## ,-----
## |	Settings
## +-----
#
#HOST_GCC_PKG:=gcc
##HOST_GCC_VER:=2.95.3
#HOST_GCC_VER:=4.1.2
##HOST_GCC_VER:=4.3.3
## requires gmp, mfpr: HOST_GCC_VER:=4.3.3
#
#HOST_GCC_SRC=${SRCDIR}/g/gcc-core-${HOST_GCC_VER}.tar.bz2
#URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-core-4.3.3.tar.bz2
#
#HOST_GCC_TEMP=nis-host-gcc-${HOST_GCC_VER}
#
#
## ,-----
## |	Package extract
## +-----
#
## 1. Atypical: keeps source and build directories separate
## TODO: patching?
#
#HOST_GCC_EXTRACTED=${EXTTEMP}/${HOST_GCC_TEMP}/gcc-${HOST_GCC_VER}/Makefile.in
#
#${HOST_GCC_EXTRACTED}:
#	[ ! -r ${EXTTEMP}/gcc-${HOST_GCC_VER} ] || rm -rf ${EXTTEMP}/gcc-${HOST_GCC_VER}
#	[ ! -r ${EXTTEMP}/${HOST_GCC_TEMP} ] || rm -rf ${EXTTEMP}/${HOST_GCC_TEMP}
#	make extract ARCHIVES="${HOST_GCC_SRC}"
#	mkdir -p ${EXTTEMP}/${HOST_GCC_TEMP}
#	mv ${EXTTEMP}/gcc-${HOST_GCC_VER} ${EXTTEMP}/${HOST_GCC_TEMP}/
#
#
## ,-----
## |	Package configure
## +-----
#
#HOST_GCC_CONFIGURED=${EXTTEMP}/${HOST_GCC_TEMP}/config.status
#
#${HOST_GCC_CONFIGURED}: ${HOST_GCC_EXTRACTED}
#	( cd ${EXTTEMP}/${HOST_GCC_TEMP} || exit 1 ;\
#	  CC=${NATIVE_CC} \
#		AR=$(shell echo ${NATIVE_CC} | sed 's/g*cc$$/ar/') \
#		CFLAGS='-O2' \
#		  ./gcc-${HOST_GCC_VER}/configure -v \
#			--prefix=${NIS_ROOT}/usr \
#			--host=${NATIVE_SPEC} \
#			--build=${NATIVE_SPEC} \
#			--target=${NATIVE_SPEC} \
#			--program-prefix=${NATIVE_SPEC}- \
#			--with-sysroot=${NATIVE_LIBCINST} \
#			--with-lib-path=${NATIVE_LIBCINST}/lib:${NATIVE_LIBCINST}/usr/lib/ \
#			--enable-shared \
#			--disable-largefile --disable-nls \
#			|| exit 1 \
#	)
#
#
## ,-----
## |	Package build
## +-----
#
#HOST_GCC_BUILT=${EXTTEMP}/${HOST_GCC_TEMP}/gcc/xgcc
#
#${HOST_GCC_BUILT}: ${HOST_GCC_CONFIGURED}
#	( cd ${EXTTEMP}/${HOST_GCC_TEMP} || exit 1 ;\
#		make \
#	)
#
#
## ,-----
## |	Package install
## +-----
#
#HOST_GCC_INSTALLED=${NIS_ROOT}/usr/bin/${NATIVE_SPEC}-gcc
#
#${HOST_GCC_INSTALLED}: ${HOST_GCC_BUILT}
#	( cd ${EXTTEMP}/${HOST_GCC_TEMP} || exit 1 ;\
#		make install \
#	)
#
#
## ,-----
## |	Trigger rule
## +-----
#
#.PHONY: nis-host-gcc
#nis-host-gcc: nis-host-binutils ${HOST_GCC_INSTALLED}

.PHONY: all-NTI
all-NTI: nti-gcc-installed
