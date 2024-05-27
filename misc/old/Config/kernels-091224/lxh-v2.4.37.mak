# linux headers 2.4.37		[ since 2.0.37pre10 ]
# last mod WmT, 2009-01-21	[ (c) and GPLv2 1999-2009 ]

# ,-----
# |	Settings
# +-----

LXHEADERS_PKG:=lxheaders
#LXHEADERS_VER:=2.2.26
#LXHEADERS_VER:=2.4.34.1
LXHEADERS_VER:=2.4.37
#LXHEADERS_VER:=2.6.20.1

LXHEADERS_SRC+=${SOURCEROOT}/l/linux-${LXHEADERS_VER}.tar.bz2
#LXHEADERS_SRC+=${SOURCEROOT}/l/linux-${LXHEADERS_VER}.tar.gz

LXHEADERS_PATH:=linux-${LXHEADERS_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/kernel/v2.4/linux-${LXHEADERS_VER}.tar.bz2

#DEPS:=

# ,-----
# |	Configure [xtc]
# +-----

LXHEADERS_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')

ifeq (${TARGET_CPU},mipsel)
LXHEADERS_ARCH_OPTS:=ARCH=mips
else
LXHEADERS_ARCH_OPTS:=ARCH=${TARGET_CPU}
endif

LXHEADERS_ARCH_OPTS+= CROSS_COMPILE=${XTC_ROOT}/usr/bin/${LXHEADERS_TARGET_SPEC}-
LXHEADERS_ARCH_OPTS+= CONFIG_SHELL=${CONFIG_SHELL}

ifeq (${ETCDIR},)
ETCDIR:=${XTC_ROOT}/etc
endif


${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.config:
	[ ! -d ${EXTTEMP}/${LXHEADERS_PATH} ] || rm -rf ${EXTTEMP}/${LXHEADERS_PATH}
	${MAKE} extract LIST="$(strip ${LXHEADERS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${LXHEADERS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${LXHEADERS_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/lxheaders-${LXHEADERS_VER} ] || rm -rf ${EXTTEMP}/lxheaders-${LXHEADERS_VER}
	mv ${EXTTEMP}/${LXHEADERS_PATH} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}
	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
		case "${LXHEADERS_VER}" in \
		2.0.*) \
			sed 's%</dev/tty%%' scripts/Configure > scripts/Configure.auto || exit 1 ;\
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
			cat Makefile.OLD \
				| sed	' /^HOSTCC/	s%gcc%'${NATIVE_GCC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /^	/ s%scripts/Configure%scripts/Configure.auto% ' > Makefile || exit 1 ;\
			\
			make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
			make include/linux/version.h || exit 1 ;\
			touch include/linux/autoconf.h \
		;; \
		2.2.*|2.4.*) \
			make ${LXHEADERS_ARCH_OPTS} mrproper symlinks || exit 1 ;\
			make include/linux/version.h || exit 1 \
		;; \
		2.6.*) \
			make ${LXHEADERS_ARCH_OPTS} mrproper || exit 1 \
		;; \
		esac ;\
		case "${LXHEADERS_VER}-${TARGET_CPU}" in \
		2.0.*-i386) \
			sed	' /^CONFIG_M.86/	s/^/# / ; /CONFIG_M386/		s/^# // ; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' arch/i386/defconfig > .config || exit 1 \
		;; \
		2.2.*-i386) \
			cat arch/${TARGET_CPU}/defconfig \
				| sed	'/^CONFIG_M.86/		s/^/# /' \
				| sed	'/CONFIG_M386/		s/^# // ' \
				| sed	'/CONFIG_AFFS_FS[= ]/	s/^# //' \
				| sed	'/CONFIG_BLK_DEV_LOOP[= ]/	s/^# //' \
				| sed	'/CONFIG_BLK_DEV_RAM[= ]/	s/^# //' \
				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
				> .config ;\
			echo "CONFIG_BLK_DEV_INITRD=y" >> .config ;\
			echo "CONFIG_PARIDE_PCD=y" >> .config ;\
			echo "CONFIG_PARIDE_PT=y" >> .config \
			echo "CONFIG_MINIX_FS=y" >> .config ;\
			echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config ;\
			echo "CONFIG_APM_DO_ENABLE=y" >> .config ;\
			echo "CONFIG_APM_CPU_IDLE=y" >> .config ;\
			echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config ;\
			echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config ;\
			echo "CONFIG_APM_ALLOW_INTS=y" >> .config ;\
			echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config \
		;; \
		2.4.*-i386) \
			cat arch/${TARGET_CPU}/defconfig \
				| sed	'/CONFIG_MPENT/		s/^/# /' \
				| sed	'/CONFIG_M386/		s/^# //' \
				| sed	'/CONFIG_BLK_DEV_LOOP/ s/^# //' \
				| sed	'/CONFIG_BLK_DEV_RAM/	s/^# //' \
				| sed	'/CONFIG_BLK_DEV_INITRD/ s/^# //' \
				| sed	'/CONFIG_MINIX_FS/ s/^# //' \
				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
				> .config \
		;; \
		2.4.*-mips*) \
			if [ -r arch/mips/defconfig-ip22 ] ; then \
				cp arch/mips/defconfig-ip22 .config || exit 1 ;\
			else \
				cp arch/mips/defconfig .config || exit 1 ;\
			fi \
		;; \
		2.6.*-i386) \
			cat arch/${TARGET_CPU}/defconfig \
				| sed	'/^CONFIG_M.86/		s/^/# /' \
				| sed	'/CONFIG_M386/		s/^# // ' \
				| sed	'/CONFIG_APM/		s/^# // ' \
				| sed	'/CONFIG_AFFS_FS[= ]/	s/^# //' \
				| sed	'/CONFIG_BLK_DEV_LOOP[= ]/	s/^# //' \
				| sed	'/CONFIG_BLK_DEV_RAM[= ]/	s/^# //' \
				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
				> .config ;\
			echo "CONFIG_BLK_DEV_INITRD=y" >> .config ;\
			echo "CONFIG_PARIDE_PCD=y" >> .config ;\
			echo "CONFIG_PARIDE_PT=y" >> .config ;\
			echo "CONFIG_MINIX_FS=y" >> .config ;\
			echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config ;\
			echo "CONFIG_APM_DO_ENABLE=y" >> .config ;\
			echo "CONFIG_APM_CPU_IDLE=y" >> .config ;\
			echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config ;\
			echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config ;\
			echo "CONFIG_APM_ALLOW_INTS=y" >> .config ;\
			echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config \
		;; \
		2.6.*-mips*) \
			cat arch/mips/defconfig \
				| sed	'/CONFIG_EMBEDDED/	s/^# //' \
				| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
				> .config \
		;; \
		*) \
			echo "Unexpected VERSION/TARGET_CPU '${LXHEADERS_VER}'/'${TARGET_CPU}'" 1>&2 ;\
			exit 1 \
		;; \
		esac ;\
		if [ "${TARGET_CPU}-${TARGET_PLATFORM}" = 'mips-qemu' ] ; then \
			mv .config .config.real ;\
			sed '/CONFIG_QEMU=/	s/^/# /	; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' .config.real > .config || exit 1 ;\
		fi ;\
		yes '' | make ${LXHEADERS_ARCH_OPTS} oldconfig || exit 1 \
	) || exit 1

# ,-----
# |	Build [xtc]
# +-----

${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend: ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.config
	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
		case "${LXHEADERS_VER}" in \
		2.0.*|2.2.*|2.4.*) \
			make ${LXHEADERS_ARCH_OPTS} dep || exit 1 \
		;; \
		2.6.*) \
			make ${LXHEADERS_ARCH_OPTS} prepare || exit 1 \
		;; \
		*) \
			echo "Build: Unexpected VERSION/TARGET_CPU '${LXHEADERS_VER}'/'${TARGET_CPU}'" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

${ETCDIR}/linux-${LXHEADERS_VER}-config:
	${MAKE} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend
	mkdir -p ${ETCDIR}
	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
		cp .config ${ETCDIR}/linux-${LXHEADERS_VER}-config || exit 1 \
	) || exit 1

${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${LXHEADERS_VER}:
	${MAKE} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend
	mkdir -p ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/include
	mkdir -p ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${LXHEADERS_VER}
	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/include/ && tar xf - ) ;\
		( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src && ln -sf linux-${LXHEADERS_VER} linux ) || exit 1 ;\
		tar cvf - ./ | ( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux && tar xvf - ) \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade lxheaders ${LXHEADERS_VER}
endif

${XDC_INSTTEMP}/usr/include/linux:
	${MAKE} ${EXTTEMP}/lxheaders-${LXHEADERS_VER}/.depend
	mkdir -p ${XDC_INSTTEMP}/usr/include
	( cd ${EXTTEMP}/lxheaders-${LXHEADERS_VER} || exit 1 ;\
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${XDC_INSTTEMP}/usr/include/ && tar xf - ) \
	) || exit 1
 
${TOPLEV}/lxheaders-${LXHEADERS_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/include/linux
#	tar cvzf lxheaders-${LXHEADERS_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create lxheaders-${LXHEADERS_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: xtc-lxheaders
xtc-lxheaders:	${ETCDIR}/linux-${LXHEADERS_VER}-config \
		${XTC_ROOT}/usr/${TARGET_SPEC}/usr/src/linux-${LXHEADERS_VER}

.PHONY: xdc-lxheaders
ifeq (${MAKE_CHROOT},y)
xdc-lxheaders: ${XDC_INSTTEMP}/usr/include/linux
else
xdc-lxheaders: ${TOPLEV}/lxheaders-${LXHEADERS_VER}.egp
endif
