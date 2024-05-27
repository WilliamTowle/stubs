# linux 2.4.37			[ EARLIEST v2.4.??, c.????-??-?? ]
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
		make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
		make include/linux/version.h || exit 1 ;\
		make ${LXHEADERS_ARCH_OPTS} dep || exit 1 ;\
		cat arch/${TARGET_CPU}/defconfig \
			| sed	'/CONFIG_MPENT/		s/^/# /' \
			| sed	'/CONFIG_M386/		s/^# //' \
			| sed	'/CONFIG_BLK_DEV_LOOP/ s/^# //' \
			| sed	'/CONFIG_BLK_DEV_RAM/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_INITRD/ s/^# //' \
			| sed	'/CONFIG_MINIX_FS/ s/^# //' \
			| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
			> .config ;\
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
##	( cd ${EXTTEMP}/${NTI_BASBASBASBASH
##		make install \
##	)


## ,-----
## |	Build [xtc]
## +-----
#
#${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend: ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.config
#	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
#		case "${LXHEADERS_VER}" in \
#		2.0.*|2.2.*|2.4.*) \
#			make ${LXHEADERS_ARCH_OPTS} dep || exit 1 \
#		;; \
#		2.6.*) \
#			make ${LXHEADERS_ARCH_OPTS} prepare || exit 1 \
#		;; \
#		*) \
#			echo "Build: Unexpected VERSION/TARGET_CPU '${LXHEADERS_VER}'/'${TARGET_CPU}'" 1>&2 ;\
#			exit 1 \
#		;; \
#		esac \
#	) || exit 1
#
#
## ,-----
## |	Install [xtc]
## +-----
#
#${ETCDIR}/linux-${LXHEADERS_VER}-config:
#	${MAKE} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend
#	mkdir -p ${ETCDIR}
#	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
#		cp .config ${ETCDIR}/linux-${LXHEADERS_VER}-config || exit 1 \
#	) || exit 1
#
#${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${LXHEADERS_VER}:
#	${MAKE} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend
#	mkdir -p ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/include
#	mkdir -p ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${LXHEADERS_VER}
#	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
#		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/include/ && tar xf - ) ;\
#		( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src && ln -sf linux-${LXHEADERS_VER} linux ) || exit 1 ;\
#		tar cvf - ./ | ( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux && tar xvf - ) \
#	) || exit 1
#ifeq (${HAVE_PTRACKING},y)
#	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade lxheaders ${LXHEADERS_VER}
#endif
#
#${LXHEADERS_INSTTEMP}/usr/include/linux:
#	${MAKE} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend
#	mkdir -p ${LXHEADERS_INSTTEMP}/usr/include
#	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
#		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${LXHEADERS_INSTTEMP}/usr/include/ && tar xf - ) \
#	) || exit 1
#
#${TOPLEV}/${LXHEADERS_EGPNAME}.egp: ${LXHEADERS_INSTTEMP}/usr/include/linux
#	${PCREATE_SCRIPT} create ${TOPLEV}/${LXHEADERS_EGPNAME}.egp ${LXHEADERS_INSTTEMP}
#
#${XDC_ROOT}/usr/include/linux: ${TOPLEV}/${LXHEADERS_EGPNAME}.egp
#	mkdir -p ${XDC_ROOT}
#	${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${LXHEADERS_EGPNAME}.egp
#
#REALCLEAN_TARGETS+= ${TOPLEV}/${LXHEADERS_EGPNAME}.egp
#
#
## ,-----
## |	Entry points [htc]
## +-----
#
#.PHONY: xtc-lxheaders
#xtc-lxheaders:	${ETCDIR}/linux-${LXHEADERS_VER}-config \
#		${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${LXHEADERS_VER}
#
#.PHONY: xdc-lxheaders
#ifeq (${MAKE_CHROOT},y)
#xdc-lxheaders: ${XDC_ROOT}/usr/include/linux
#else
#xdc-lxheaders: ${TOPLEV}/${LXHEADERS_EGPNAME}.egp
#endif

.PHONY: all-NTI
#all-NTI: nti-linux-extracted
all-NTI: nti-linux-configured
#all-NTI: nti-linux-built
#all-NTI: nti-linux-installed
