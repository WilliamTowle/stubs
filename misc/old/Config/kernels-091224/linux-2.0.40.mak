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
			| sed	' /^HOSTCC/	s%gcc%'${NATIVE_GCC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /^	/ s%scripts/Configure%scripts/Configure.auto% ' > Makefile || exit 1 ;\
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
##	( cd ${EXTTEMP}/${NTI_BASBASBASBASH
##		make install \
##	)

## linux headers 2.0.40		[ since 2.0.37pre10 ]
## last mod WmT, 09/05/2007	[ (c) and GPLv2 1999-2007 ]
#
## ,-----
## |	Settings
## +-----
#
#LXHEADERS_PKG:=lxheaders
#LXHEADERS_VER:=2.0.40
##LXHEADERS_VER:=2.2.26
##LXHEADERS_VER:=2.4.34.1
##LXHEADERS_VER:=2.6.20.1
#
#LXHEADERS_SRC+=${SOURCEROOT}/l/linux-${LXHEADERS_VER}.tar.bz2
##LXHEADERS_SRC+=${SOURCEROOT}/l/linux-${LXHEADERS_VER}.tar.gz
#
#LXHEADERS_PATH:=linux-${LXHEADERS_VER}
#LXHEADERS_INSTTEMP:=${EXTTEMP}/lxheaders-${LXHEADERS_VER}-insttemp
#LXHEADERS_EGPNAME:=lxheaders-${LXHEADERS_VER}
#
#URLS+=http://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/kernel/v2.0/linux-2.0.40.tar.bz2
#
##DEPS:=
#
## ,-----
## |	Configure [xtc]
## +-----
#
#LXHEADERS_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')
#
#ifeq (${TARGET_CPU},mipsel)
#LXHEADERS_ARCH_OPTS:=ARCH=mips
#else
#LXHEADERS_ARCH_OPTS:=ARCH=${TARGET_CPU}
#endif
#
#LXHEADERS_ARCH_OPTS+= CROSS_COMPILE=${XTC_ROOT}/usr/bin/${LXHEADERS_TARGET_SPEC}-
## not 2.6.x? LXHEADERS_ARCH_OPTS+=CONFIG_SHELL=${CONFIG_SHELL}
#
#ifeq (${ETCDIR},)
#ETCDIR:=${XTC_ROOT}/etc
#endif
#
#
#${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.config:
#	[ ! -d ${EXTTEMP}/${LXHEADERS_PATH} ] || rm -rf ${EXTTEMP}/${LXHEADERS_PATH}
#	${MAKE} extract LIST="$(strip ${LXHEADERS_SRC})"
##	echo "*** PATCHING ***"
##	( cd ${EXTTEMP} || exit 1 ;\
##		for PF in ${LXHEADERS_PKG}*patch ; do \
##			cat $${PF} | ( cd ${LXHEADERS_PATH} && patch -Np1 -i - ) ;\
##			rm -f $${PF} ;\
##		done \
##	) || exit 1
#	[ ! -d ${EXTTEMP}/lxheaders-${LXHEADERS_VER} ] || rm -rf ${EXTTEMP}/lxheaders-${LXHEADERS_VER}
#	mv ${EXTTEMP}/${LXHEADERS_PATH} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}
#	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
#		case "${LXHEADERS_VER}" in \
#		2.0.*) \
#			sed 's%</dev/tty%%' scripts/Configure > scripts/Configure.auto || exit 1 ;\
#			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
#			cat Makefile.OLD \
#				| sed	' /^HOSTCC/	s%gcc%'${NATIVE_GCC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /^	/ s%scripts/Configure%scripts/Configure.auto% ' > Makefile || exit 1 ;\
#			\
#			make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
#			make include/linux/version.h || exit 1 ;\
#			touch include/linux/autoconf.h \
#		;; \
#		2.2.*|2.4.*) \
#			make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
#			make include/linux/version.h || exit 1 \
#		;; \
#		2.6.*) \
#			make ${LXHEADERS_ARCH_OPTS} mrproper || exit 1 \
#		;; \
#		esac ;\
#		case "${LXHEADERS_VER}-${TARGET_CPU}" in \
#		2.0.*-i386) \
#			sed	' /^CONFIG_M.86/	s/^/# / ; /CONFIG_M386/		s/^# // ; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' arch/i386/defconfig > .config || exit 1 \
#		;; \
#		2.2.*-i386) \
#			cat arch/${TARGET_CPU}/defconfig \
#				| sed	'/^CONFIG_M.86/		s/^/# /' \
#				| sed	'/CONFIG_M386/		s/^# // ' \
#				| sed	'/CONFIG_AFFS_FS[= ]/	s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_LOOP[= ]/	s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_RAM[= ]/	s/^# //' \
#				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
#				> .config ;\
#			echo "CONFIG_BLK_DEV_INITRD=y" >> .config ;\
#			echo "CONFIG_PARIDE_PCD=y" >> .config ;\
#			echo "CONFIG_PARIDE_PT=y" >> .config \
#			echo "CONFIG_MINIX_FS=y" >> .config ;\
#			echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config ;\
#			echo "CONFIG_APM_DO_ENABLE=y" >> .config ;\
#			echo "CONFIG_APM_CPU_IDLE=y" >> .config ;\
#			echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config ;\
#			echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config ;\
#			echo "CONFIG_APM_ALLOW_INTS=y" >> .config ;\
#			echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config \
#		;; \
#		2.4.*-i386) \
#			cat arch/${TARGET_CPU}/defconfig \
#				| sed	'/CONFIG_MPENT/		s/^/# /' \
#				| sed	'/CONFIG_M386/		s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_LOOP/ s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_RAM/	s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_INITRD/ s/^# //' \
#				| sed	'/CONFIG_MINIX_FS/ s/^# //' \
#				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
#				> .config \
#		;; \
#		2.4.*-mips*) \
#			if [ -r arch/mips/defconfig-ip22 ] ; then \
#				cp arch/mips/defconfig-ip22 .config || exit 1 ;\
#			else \
#				cp arch/mips/defconfig .config || exit 1 ;\
#			fi \
#		;; \
#		2.6.*-i386) \
#			cat arch/${TARGET_CPU}/defconfig \
#				| sed	'/CONFIG_MPENT/		s/^/# /' \
#				| sed	'/CONFIG_M386/		s/^# //' \
#				| sed	'/CONFIG_EMBEDDED/	s/^# //' \
#				| sed	'/CONFIG_LOCALVERSION/	s/""/"mine"/' \
#				| sed	'/CONFIG_IKCONFIG/	s/^/# /' \
#				| sed	'/CONFIG_MATH_EMULATION/ s/^# //' \
#				| sed	'/CONFIG_SOFTWARE_SUSPEND/ s/^/# /' \
#				| sed	'/CONFIG_BLK_DEV_LOOP/ s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_RAM/ s/^# //' \
#				| sed	'/CONFIG_BLK_DEV_INITRD/ s/^# //' \
#				| sed	'/CONFIG_MINIX_FS/ s/^# //' \
#				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
#				> .config \
#		;; \
#		2.6.*-mips*) \
#			cat arch/mips/defconfig \
#				| sed	'/CONFIG_EMBEDDED/	s/^# //' \
#				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
#				> .config \
#		;; \
#		*) \
#			echo "Unexpected VERSION/TARGET_CPU '${LXHEADERS_VER}'/'${TARGET_CPU}'" 1>&2 ;\
#			exit 1 \
#		;; \
#		esac ;\
#		if [ "${TARGET_CPU}-${TARGET_PLATFORM}" = 'mips-qemu' ] ; then \
#			mv .config .config.real ;\
#			sed '/CONFIG_QEMU=/	s/^/# /	; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' .config.real > .config || exit 1 ;\
#		fi ;\
#		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig || exit 1 \
#	) || exit 1
#
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
#all-NTI: nti-linux-configured
all-NTI: nti-linux-built
#all-NTI: nti-linux-installed
