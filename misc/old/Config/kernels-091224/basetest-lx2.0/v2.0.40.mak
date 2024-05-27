# lx20 2.0.40			[ since v2.0.39, c.2002-11-11 ]
# last mod WmT, 2009-10-10	[ (c) and GPLv2 1999-2009 ]

include ${TOPLEV}/Config/platform-bt.mak

ifneq (${HAVE_LX20_CONFIG},y)
HAVE_LX20_CONFIG:=y

#include Config/gcc2723/v2.7.2.3.mak
#include Config/xtc-min-binutils/v2.16.1.mak

DESCRLIST+= "'htc-lx20' -- linux 2.0 kernel"

LX20_VER:=2.0.40

HTC_LX20_SRC:=${SRCDIR}/l/linux-${LX20_VER}.tar.bz2

URLS+= http://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/kernel/v2.0/linux-${PKGVER}.tar.bz2

#LX20_GCC=${HTC_ROOT}/usr/bin/${TARGET_LEG_TRIPLET}-gcc
LX20_GCC=gcc
LX20_GCCINCDIR=$(shell ${HTC_LX20_GCC} -v 2>&1 | grep specs | sed 's/.* // ; s/specs/include/')


## ,-----
## |	package extract
## +-----

HTC_LX20_TEMP=htc-linux-${LX20_VER}
HTC_LX20_EXTRACTED=${EXTTEMP}/${HTC_LX20_TEMP}/Makefile

.PHONY: htc-lx20-extracted
htc-lx20-extracted: ${HTC_LX20_EXTRACTED}

## 1. Fix $ARCH to suit build target
## 2. Configure.auto allows piping 'yes' to 'make oldconfig' in lx2.0
${HTC_LX20_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${LX20_VER} ${HTC_LX20_SRC}
	[ ! -r ${EXTTEMP}/${HTC_LX20_TEMP} ] || rm -rf ${EXTTEMP}/${HTC_LX20_TEMP}
	mv ${EXTTEMP}/linux-${LX20_VER} ${EXTTEMP}/${HTC_LX20_TEMP}
	( cd ${EXTTEMP}/${HTC_LX20_TEMP} || exit 1 ;\
		mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^ARCH/ { s/^/#/ ; s/$$/\nARCH:= '${TARGET_CPU}'/ }' \
			| sed '/^CROSS_COMPILE/ s%$$%'${TARGET_MIN_SPEC}'-%' \
			| sed '/^CC/ s%$$.*%'${LX20_GCC}'%' \
			| sed '/^	/ s%scripts/Configure%scripts/Configure.auto% ' \
			> Makefile ;\
		sed 's%dev/tty%dev/stdin%' scripts/Configure > scripts/Configure.auto || exit 1 \
	)


## ,-----
## |	package configure
## +-----

HTC_LX20_CONFIGURED=${EXTTEMP}/${LX20_TEMP}/.config

.PHONY: htc-lx20-configured
htc-lx20-configured: htc-lx20-extracted ${HTC_LX20_CONFIGURED}

## *. Fix 2.9x configure: copying 'no' tree shouldn't grab the source
## *. --with-headers, --with-lib: target new (htc-local) C library
${HTC_LX20_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${HTC_LX20_TEMP} || exit 1 ;\
		make mrproper || exit 1 ;\
		make include/linux/version.h ;\
		make symlinks ;\
		( cat arch/${TARGET_CPU}/defconfig \
			| sed 's%#* *CONFIG_PARIDE_PCD[= ].*%##CONFIG_PARIDE_PCD: %' \
			| sed 's%#* *CONFIG_PARIDE_PT[= ].*%##CONFIG_PARIDE_PT: %' \
			| sed 's%#* *CONFIG_AFFS_FS[= ].*%##CONFIG_AFFS_FS: %' ;\
		  echo "CONFIG_PARIDE_PCD=y" ;\
		  echo "CONFIG_PARIDE_PT=y" ;\
		  echo "CONFIG_AFFS_FS=y" \
		) > .config || exit 1 ;\
		yes '' | make oldconfig || exit 1 ;\
	)
	mkdir -p ${HTC_ROOT}/etc
	cp ${EXTTEMP}/${HTC_LX20_TEMP}/.config ${HTC_ROOT}/etc/bt-config-lx${LX20_VER}

#### ,-----
#### |	package build
#### +-----
#
#LX20_BUILT=${EXTTEMP}/arch/${TARGET_CPU}/boot/bzImage
#
#.PHONY: htc-lx20-built
#htc-lx20-built: htc-lx20-configured ${HTC_LX20_BUILT}
#
### 1. Ensure native CC builds native code
### 2. Ensure legacy CC builds kernel
### 3. Overridden ${CC} must specify includes or assembly builds fail
#${HTC_LX20_BUILT}:
#	echo "*** $@ (BUILT) ***"
#	( cd ${EXTTEMP}/${HTC_LX20_TEMP} || exit 1 ;\
#		rm scripts/mkdep >/dev/null 2>&1 ;\
#		make HOSTCC=${NATIVE_CC} dep || exit 1 ;\
#		make bzImage CC="${LX20_GCC} -D__KERNEL__ -nostdinc -I${EXTTEMP}/${HTC_LX20_TEMP}/include -I${HTC_LX20_GCCINCDIR}" CFLAGS="-O2 -fomit-frame-pointer" || exit 1 \
#	)
#
### ,-----
### |	package install
### +-----
#
#LX20_INSTALLED=${HTC_ROOT}/usr/bin/${HOSTTC_SPEC}-gcc
#
#.PHONY: lx20-installed
#lx20-installed: lx20-built ${HTC_LX20_INSTALLED}
#
#${HTC_LX20_INSTALLED}: ${HTC_ROOT}
#	echo "*** $@ (INSTALLED) ***"
#	( cd ${EXTTEMP}/${HTC_LX20_TEMP} || exit 1 ;\
#		echo "?" 1>&2 ; exit 1 \
#	)
#
#.PHONY: lx20
#lx20: gcc2723 xtc-min-binutils-installed lx20-installed

HTC_TARGETS+= htc-lx20-configured
#HTC_TARGETS+= htc-lx20-installed

endif	# HAVE_LX20_CONFIG
