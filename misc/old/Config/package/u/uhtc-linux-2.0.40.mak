# linux 2.0.40			[ EARLIEST v2.0.37pre10, c.????-??-?? ]
# last mod WmT, 2009-12-24	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

NTI_LINUX_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}


## ,-----
## |	package extract
## +-----

NTI_LINUX_TEMP=nti-linux-${PKG_VER}
NTI_LINUX_EXTRACTED=${EXTTEMP}/${NTI_LINUX_TEMP}/Makefile

.PHONY: nti-linux-extracted
nti-linux-extracted: ${NTI_LINUX_EXTRACTED}

${NTI_LINUX_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} linux-${PKG_VER} ${NTI_LINUX_SRC}
	[ ! -r ${EXTTEMP}/${NTI_LINUX_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_LINUX_TEMP}
	mv ${EXTTEMP}/linux-${PKG_VER} ${EXTTEMP}/${NTI_LINUX_TEMP}


## ,-----
## |	package configure
## +-----

NTI_LINUX_CONFIGURED=${EXTTEMP}/${NTI_LINUX_TEMP}/.config

.PHONY: nti-linux-configured
nti-linux-configured: nti-linux-extracted ${NTI_LINUX_CONFIGURED}

${NTI_LINUX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
		sed 's%</dev/tty%%' scripts/Configure > scripts/Configure.auto || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed	' /^HOSTCC/	s%gcc%'${TARGET_MIN_SPEC}-gcc'%' \
			| sed	' /^CROSS_COMPILE/	s%$$%'${TARGET_MIN_SPEC}'-%' \
			| sed	'/^	/ s%scripts/Configure%scripts/Configure.auto% ' \
			> Makefile || exit 1 ;\
		\
		make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
		make include/linux/version.h || exit 1 ;\
		touch include/linux/autoconf.h || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} dep || exit 1 ;\
		sed	' /^CONFIG_M.86/	s/^/# / ; /CONFIG_M386/		s/^# // ; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' arch/i386/defconfig > .config || exit 1 ;\
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig \
	)


## ,-----
## |	package build
## +-----

NTI_LINUX_BUILT=${EXTTEMP}/${NTI_LINUX_TEMP}/src/diff

.PHONY: nti-linux-built
nti-linux-built: nti-linux-configured ${NTI_LINUX_BUILT}

${NTI_LINUX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
		make bzImage || exit 1 \
	)

## ,-----
## |	package install
## +-----

##NTI_LINUX_INSTALLED=${NTI_ROOT}/usr/bin/diff
##
##.PHONY: nti-linux-installed
##nti-linux-installed: nti-linux-built ${NTI_LINUX_INSTALLED}
##
##${NTI_LINUX_INSTALLED}: ${NTI_ROOT}
##	echo "*** $@ (INSTALLED) ***"
##	( cd ${EXTTEMP}/${NTI_LINUX_TEMP} || exit 1 ;\
##		make install \
##	)


.PHONY: all-NTI
#all-NTI: nti-linux-extracted
all-NTI: nti-linux-built
#all-NTI: nti-linux-installed
