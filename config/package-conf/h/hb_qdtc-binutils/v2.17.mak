#!/usr/bin/make
# hb_qdtc-binutils v2.17	STUBS (c) and GPLv2 1999-2012
# last modified			2012-06-21

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_BINUTILS_SRCROOT	= ${BUILDROOT}/${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_BINUTILS_CONFIGURED= ${CTI_BINUTILS_SRCROOT}/Makefile
CTI_BINUTILS_BUILT=	${CTI_BINUTILS_SRCROOT}/gas/as-new
CTI_BINUTILS_INSTALLED=	${TCTREE}/usr/bin/${TARGSPEC}-as


## ,-----
## |	Configure
## +-----

${CTI_BINUTILS_CONFIGURED}:
	( cd source/binutils-${PKGVER} || exit 1 ;\
		./configure --prefix=${TCTREE}/usr/ \
			--host=${HOSTSPEC} --build=${HOSTSPEC} \
			--target=${TARGSPEC} \
			--disable-nls --disable-werror \
			--with-sysroot=${TCTREE}/usr/${TARGSPEC} \
			--enable-shared \
			--disable-multilib \
	)


## ,-----
## |	Build
## +-----

${CTI_BINUTILS_BUILT}: ${CTI_BINUTILS_CONFIGURED}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make \
	)


## ,-----
## |	Install
## +-----

# Ensure we have appropriately-prefixed symlinks for the kernel
# compiler later

${CTI_BINUTILS_INSTALLED}: ${CTI_BINUTILS_BUILT}
	( cd source/binutils-${PKGVER} || exit 1 ;\
		make install ;\
		( cd ${TCTREE}/usr/bin ;\
			for EXE in addr2line ar as c++filt ld nm \
				objcopy objdump ranlib readelf size \
				strings strip ;\
			do [ ! -r ${TARGSPEC}-$${EXE} ] || ln -sf ${TARGSPEC}-$${EXE} ${TARGSPEC}-k$${EXE} ; done ;\
		) \
	)

.PHONY: cti-binutils
cti-binutils: ${CTI_BINUTILS_INSTALLED}

.PHONY: CTI
CTI: ${CTI_BINUTILS_INSTALLED}
