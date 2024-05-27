# ultc-lxincl20 v2.0.40		[ EARLIEST v2.0.37pre10, c.????-??-?? ]
# last mod WmT, 2010-01-28	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LINUX_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}


## ,-----
## |	package extract
## +-----

CTI_LINUX_TEMP=cti-linux-${PKG_VER}
CTI_LINUX_EXTRACTED=${EXTTEMP}/${CTI_LINUX_TEMP}/Makefile

.PHONY: cti-linux-extracted
cti-linux-extracted: ${CTI_LINUX_EXTRACTED}

${CTI_LINUX_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${CTI_LINUX_SRC}
	[ ! -r ${EXTTEMP}/${CTI_LINUX_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_LINUX_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${CTI_LINUX_TEMP}


## ,-----
## |	package configure
## +-----

CTI_LINUX_CONFIGURED=${EXTTEMP}/${CTI_LINUX_TEMP}/.config

.PHONY: cti-linux-configured
cti-linux-configured: cti-linux-extracted ${CTI_LINUX_CONFIGURED}

${CTI_LINUX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
		sed 's%</dev/tty%%' scripts/Configure > scripts/Configure.auto || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed '/^HOSTCC/	s%gcc%'${NATIVE_GCC}'%' \
			| sed '/^CROSS_COMPILE/	s%$$%'${TARGET_MIN_SPEC}'-%' \
			| sed '/^	/ s%scripts/Configure%scripts/Configure.auto%' \
			> Makefile || exit 1 ;\
		\
		make mrproper symlinks || exit 1 ;\
		make include/linux/version.h || exit 1 ;\
		touch include/linux/autoconf.h || exit 1 ;\
		make dep || exit 1 ;\
		sed	' /^CONFIG_M.86/	s/^/# / ; /CONFIG_M386/		s/^# // ; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' arch/i386/defconfig > .config || exit 1 ;\
		yes '' | make oldconfig \
	)


### ,-----
### |	package build
### +-----
#
#CTI_LINUX_BUILT=${EXTTEMP}/${CTI_LINUX_TEMP}/src/diff
#
#.PHONY: cti-linux-built
#cti-linux-built: cti-linux-configured ${CTI_LINUX_BUILT}
#
#${CTI_LINUX_BUILT}:
#	echo "*** $@ (BUILT) ***"
#	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
#		make bzImage || exit 1 \
#	)
#
### ,-----
### |	package install
### +-----
#
##CTI_LINUX_INSTALLED=${CTI_ROOT}/usr/bin/diff
##
##.PHONY: cti-linux-installed
##cti-linux-installed: cti-linux-built ${CTI_LINUX_INSTALLED}
##
##${CTI_LINUX_INSTALLED}: ${CTI_ROOT}
##	echo "*** $@ (INSTALLED) ***"
##	( cd ${EXTTEMP}/${CTI_LINUX_TEMP} || exit 1 ;\
##		make install \
##	)


.PHONY: all-CTI
all-CTI: cti-linux-extracted
all-CTI: cti-linux-configured
#all-CTI: cti-linux-built
#all-CTI: cti-linux-installed
