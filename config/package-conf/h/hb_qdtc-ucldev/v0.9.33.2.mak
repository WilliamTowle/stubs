#!/usr/bin/make
# hb_qdtc-ucldev v0.9.33.2   	STUBS (c) and GPLv2 1999-2014
# last modified			2014-07-09

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CTI_UCLDEV_SRCROOT	= ${BUILDROOT}/CTI-${PKGNAME}-${PKGVER}/source/linux-${PKGVER}

# STUBS: source extracted by controlling script

CTI_UCLDEV_CONFIGURED	= ${CTI_UCLDEV_SRCROOT}/.config.old
CTI_UCLDEV_BUILT	= ${CTI_UCLDEV_SRCROOT}/lib/ld-uClibc-0.9.33.2.so
CTI_UCLDEV_INSTALLED	= ${TCTREE}/etc/config-uClibc-${PKGVER}


## ,-----
## |	Configure
## +-----

# Observed in v0.9.33.2:
# - UCLIBC_HAS_GNU_GLOB required by 'make'
# - UCLIBC_HAS_THREADS generally useful
# - DO_C99_MATH provides rint() (alsa-lib, amongst others)
# - WCHAR lack prompts mblen, mbtowc, mbstowcs, wctomb link error in libXpm
# - UCLIBC_HAS_LOCALE useful? or dubious dependency?
# - LINUXTHREADS_NEW, HAS_THREADS_NATIVE required by pixman
# - UCLIBC_HAS_SSP, required by perl
# - testing UCLIBC_HAS_RESOLVER_SUPPORT, required by openssh
# - testing UCLIBC_HAS_{GETPT|LIBUTIL}, useful for openssh/terminal emulation?
# - ?test UCLIBC_HAS_{GETPT+LIBUTIL}, useful for openssh X11 forwarding
# - UNIX98PTY_ONLY=y causes UCLIBC_HAS_PTY to exist ('screen' support)

## 2014-05-03: WARNINGS is not honoured by Rules.mak content :(
## ... -Wall, implies -Warray-bounds
## ... building LOCALEs requires locale support on build host :(

${CTI_UCLDEV_CONFIGURED}:
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		( \
	 	 echo 'TARGET_ARCH="'${TARGCPU}'"' ;\
	 	 echo 'TARGET_'${TARGCPU}'=y' ;\
		 echo 'CROSS_COMPILER_PREFIX="'${TARGSPEC}'-k"' ;\
		 \
		 echo 'KERNEL_HEADERS="'${TCTREE}'/usr/'${TARGSPEC}'/usr/include/"' ;\
		 echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
	 	 echo 'DEVEL_PREFIX="/usr/"' ;\
		 echo 'RUNTIME_PREFIX="/"' ;\
		 echo 'WARNINGS=""' ;\
		 \
		 echo 'DO_C99_MATH=y' ;\
		 echo 'MALLOC_GLIBC_COMPAT=y' ;\
		 echo 'UCLIBC_HAS_THREADS=y' ;\
		 echo 'LINUXTHREADS_NEW=y' ;\
		 echo 'UCLIBC_HAS_THREADS_NATIVE=y' ;\
		 echo 'UCLIBC_HAS_SSP=y' ;\
		 echo '# UCLIBC_HAS_LOCALE is not set' ;\
		 echo 'UCLIBC_HAS_WCHAR=y' ;\
		 echo 'UCLIBC_SUSV3_LEGACY=y' ;\
		 echo 'UCLIBC_SUSV4_LEGACY=y' ;\
		 echo 'UCLIBC_HAS_GNU_GLOB=y' ;\
		 echo 'UCLIBC_HAS_RESOLVER_SUPPORT=y' ;\
		 echo 'UNIX98PTY_ONLY=y' ;\
		 echo 'UCLIBC_HAS_GETPT=y' ;\
		 echo 'UCLIBC_HAS_LIBUTIL=y?' \
	 	) > .config ;\
	 	yes '' | ${MAKE} HOSTCC=/usr/bin/gcc oldconfig \
	)
#		[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1 ;\
#		cat Rules.mak.OLD \
#			| sed '/^BUILD_CFLAGS/	s/-Wall//' \
#			> Rules.mak ;\


## ,-----
## |	Build
## +-----

## [2014-05-04] set VERBOSE to non-empty string for detailed output

${CTI_UCLDEV_BUILT}: ${CTI_UCLDEV_CONFIGURED}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		${MAKE} headers startfiles VERBOSE=y \
	)


## ,-----
## |	Install
## +-----

# 1. CDPATH='' for install_headers due to `(cd ...) | ...` use
#? use full compiler for runtime components build? or is libgcc special?
${CTI_UCLDEV_INSTALLED}: ${CTI_UCLDEV_BUILT}
	( cd source/uClibc-${PKGVER} || exit 1 ;\
		CDPATH='' make PREFIX=${TCTREE}'/usr/'${TARGSPEC}'/' install_headers install_startfiles || exit 1 ;\
		mkdir -p ${TCTREE}/etc/ ;\
		cp .config ${CTI_UCLDEV_INSTALLED} \
	)

.PHONY: cti-ucldev
cti-ucldev: ${CTI_UCLDEV_INSTALLED}

.PHONY: CTI
CTI: ${CTI_UCLDEV_INSTALLED}
