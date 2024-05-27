#!/bin/sh
# 2008-08-15

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	make ARCH=${TARGET_CPU} \
		  mrproper \
		  include/linux/version.h \
		  symlinks || exit 1
	touch include/linux/autoconf.h || exit 1

	case "${TARGET_CPU}-${PKGVER}" in
	i386-2.0.40)
		if [ -r ${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-2.7.2.3-gnu-kgcc ] ; then
			FR_KERNEL_CC=${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-2.7.2.3-gnu-kgcc
		else
			# try uClibc's cross-compiler, if we've built it
			FR_KERNEL_CC=${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-gcc
		fi

		sed 's%dev/tty%dev/stdin%' scripts/Configure > scripts/Configure.auto || exit 1
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^ARCH *:=/	s/=.*/= '${TARGET_CPU}'/' \
			| sed	' /^HOSTCC[ 	]*=/	s%gcc%'${FR_HOST_CC}'%' \
			| sed	'/^	/ s%scripts/Configure%scripts/Configure.auto% ' \
			> Makefile || exit 1
	;;
	i386-2.2.26)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed	' /^ARCH *:=/	s/=.*/= '${TARGET_CPU}'/' \
			| sed '/^HOSTCC[ 	]=/	s%gcc%'${FR_HOST_CC}'%' \
			> Makefile || exit 1
		[ -r arch/i386/boot/Makefile.OLD ] || mv arch/i386/boot/Makefile arch/i386/boot/Makefile.OLD || exit 1
		cat arch/i386/boot/Makefile.OLD \
			| sed '/^..86[ 	]=/	s%$(CROSS_COMPILE)%'${FR_TH_ROOT}'/usr/bin/%' \
			> arch/i386/boot/Makefile || exit 1

		cat arch/${TARGET_CPU}/defconfig \
			| sed	'/^CONFIG_M.86/		s/^/# /' \
			| sed	'/CONFIG_M386/		s/^# // ' \
			| sed	'/CONFIG_APM/		s/^# // ' \
			| sed	'/CONFIG_USB/		s/^# // ' \
			| sed	'/CONFIG_AFFS_FS[= ]/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_LOOP[= ]/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_RAM[= ]/	s/^# //' \
			| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
			> .config
		echo "CONFIG_HOTPLUG=y" >> .config
		echo "CONFIG_BLK_DEV_INITRD=y" >> .config
		echo "CONFIG_PARIDE_PCD=y" >> .config
		echo "CONFIG_PARIDE_PT=y" >> .config
		echo "CONFIG_MINIX_FS=y" >> .config
		echo "CONFIG_UMSDOS_FS=y" >> .config
		echo "CONFIG_FAT_FS=y" >> .config
		echo "CONFIG_VFAT_FS=y" >> .config
		echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config
		echo "CONFIG_APM_DO_ENABLE=y" >> .config
		echo "CONFIG_APM_CPU_IDLE=y" >> .config
		echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config
		echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config
		echo "CONFIG_APM_ALLOW_INTS=y" >> .config
		echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config
		echo "CONFIG_USB_UCHI=y" >> .config
		echo "CONFIG_USB_OCHI=y" >> .config
		echo "CONFIG_USB_HID=y" >> .config
		echo "CONFIG_INPUT_KEYBDEV=y" >> .config
	;;
	*)
		echo "Unexpected TARGET_CPU '${TARGET_CPU}' or PKGVER '${PKGVER}'" 1>&2
		exit 1
	;;
	esac

	case ${PHASE} in
	th)
		yes '' | make ARCH=${TARGET_CPU} oldconfig || exit 1
		mkdir -p ${TCTREE}/etc/${USE_TOOLCHAIN} || exit 1
		cp .config ${TCTREE}/etc/${USE_TOOLCHAIN}/linux-${PKGVER}-config || exit 1
	;;
	dc)
		cp ${TCTREE}/etc/${USE_TOOLCHAIN}/linux-${PKGVER}-config .config || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=th do_configure || exit 1

# BUILD...
	make dep || exit 1


# INSTALL...
	mkdir -p ${FR_LIBCDIR}/include
	( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )

	# uClibc 0.9.26 needs the kernel Makefile
	mkdir -p ${FR_KERNSRC}-${PKGVER}
	( cd `dirname ${FR_KERNSRC}` && ln -sf linux-${PKGVER} linux ) || exit 1
	tar cvf - ./ | ( cd ${FR_KERNSRC} && tar xvf - )
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	make dep || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/include || exit 1
	( cd include >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${INSTTEMP}/usr/include/ && tar xf - )

#	mkdir -p ${INSTTEMP}/usr/src/linux-${PKGVER} || exit 1
#	( cd ${INSTTEMP}/usr/src && ln -sf linux-${PKGVER} linux ) || exit 1
#	tar cvf - ./ | ( cd ${INSTTEMP}/usr/src/linux && tar xvf - )
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Bad COMMAND $1" 1>&2
	exit 1
;;
esac
