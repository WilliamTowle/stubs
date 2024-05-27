#!/bin/sh
# 2008-08-15

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	make ARCH=${TARGET_CPU} mrproper || exit 1
	case ${PKGVER} in
	2.0.*)
		# v2.6.x 'symlinks' requires configured kernel!
		make ${ARCH_OPTS} \
			symlinks \
			include/linux/version.h || exit 1
		touch include/linux/autoconf.h || exit 1
	;;
	2.2.*|2.4.*)
		# v2.6.x 'symlinks' requires configured kernel!
		make ${ARCH_OPTS} \
			symlinks \
			include/linux/version.h || exit 1
	;;
	esac

	case "${TARGET_CPU}-${PKGVER}" in
	i386-2.6.*)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^HOSTCC/	s%gcc%'${FR_HOST_CC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$$//'`'" ; fi)% ' \
			> Makefile || exit 1

		if [ -d arch/x86 ] ;then
			DEFCFG=arch/x86/configs/i386_defconfig
		else
			DEFCFG=arch/i386/defconfig
		fi
		if [ ! -r ${DEFCFG} ] ; then
			echo "$0: No DEFCFG ${DEFCFG}" 1>&2
		fi
		cat ${DECFG} \
			| sed '/CONFIG_M.86/	s/^# //' \
			| sed	'/CONFIG_HOTPLUG/	s/^# // ' \
			| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
			> .config
		echo "CONFIG_EXPERIMENTAL=y" >> .config
		echo "CONFIG_MPENTIUMM=y" >> .config
		echo "CONFIG_ATA=y" >> .config
		echo "CONFIG_ATA_PIIX=y" >> .config
		echo "CONFIG_SATA_AHCI=y" >> .config
		echo "CONFIG_BLK_DEV_SD=y" >> .config
		echo "CONFIG_HOTPLUG_PCI=y" >> .config
		echo "CONFIG_PCIEPORTBUS=y" >> .config
		echo "CONFIG_HOTPLUG_PCI_PCIE=y" >> .config # 2.6.27.1
		echo "CONFIG_USB=y" >> .config
		echo 'CONFIG_BLK_DEV_LOOP=y' >> .config
		echo "CONFIG_BLK_DEV_RAM=y" >> .config
		echo "CONFIG_BLK_DEV_INITRD=y" >> .config
		echo "CONFIG_PARIDE_PCD=y" >> .config
		echo "CONFIG_PARIDE_PT=y" >> .config
		echo "CONFIG_MINIX_FS=y" >> .config
		echo "CONFIG_APM_IGNORE_USER_SUSPEND=y" >> .config
		echo "CONFIG_APM_DO_ENABLE=y" >> .config
		echo "CONFIG_APM_CPU_IDLE=y" >> .config
		echo "CONFIG_APM_DISPLAY_BLANK=y" >> .config
		echo "# CONFIG_APM_RTC_IS_GMT is not set" >> .config
		echo "CONFIG_APM_ALLOW_INTS=y" >> .config
		echo "CONFIG_APM_REAL_MODE_POWER_OFF=y" >> .config
	;;
	*)
		echo "Unexpected TARGET_CPU '${TARGET_CPU}' or PKGVER '${PKGVER}'" 1>&2
		exit 1
	;;
	esac

	case ${PHASE} in
	th)
		yes '' | make ${ARCH_OPTS} oldconfig || exit 1
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

	case ${TARGET_CPU} in
	mipsel)
		ARCH_OPTS="ARCH=mips CROSS_COMPILE=${FR_TC_ROOT}/usr/bin/"`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`'-'
	;;
	*)	# mips, i386...
		ARCH_OPTS="ARCH=${TARGET_CPU} CROSS_COMPILE=${FR_TC_ROOT}/usr/bin/"`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`'-'
	;;
	esac

	PHASE=th do_configure || exit 1

# BUILD...
	case "${PKGVER}" in
	2.0.*|2.2.*|2.4.*)
		make ${ARCH_OPTS} dep || exit 1
	;;
	2.6.*)
		make ${ARCH_OPTS} prepare || exit 1
	;;
	*)
		echo "Build: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
#	if [ -d ${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}-uclibc ] ; then
#		# (10/06/2007) Bogus FR_LIBCDIR (no -uclibc suffix) HACK!
#		( cd ${FR_TC_ROOT}/usr && ln -sf ${FR_TARGET_DEFN}-uclibc ${FR_TARGET_DEFN} ) || exit 1
#	else
		mkdir -p ${FR_LIBCDIR}/include
#	fi
# (10/06/2007) just this previously
#	mkdir -p ${FR_LIBCDIR}/include

	case ${TARGET_CPU} in
	i386)
		if [ -d arch/x86 ] ;then
			( cd include/ >/dev/null && tar cvf - asm asm-x86 asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )
		else
			( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )
		fi
	;;
	*)
		( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )
	;;
	esac

	# uClibc 0.9.26/28 needs the kernel Makefile
	mkdir -p ${FR_KERNSRC}-${PKGVER}
	( cd `dirname ${FR_KERNSRC}` && ln -sf linux-${PKGVER} linux ) || exit 1
	tar cvf - ./ | ( cd ${FR_KERNSRC} && tar xvf - )
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${TARGET_CPU} in
	mipsel)
		ARCH_OPTS="ARCH=mips CROSS_COMPILE=${FR_TC_ROOT}/usr/bin/"`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`'-'
	;;
	*)	# mips, i386...
		ARCH_OPTS="ARCH=${TARGET_CPU} CROSS_COMPILE=${FR_TC_ROOT}/usr/bin/"`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`'-'
	;;
	esac

	PHASE=dc do_configure || exit 1

# BUILD...
	case "${PKGVER}" in
	2.0.*|2.2.*|2.4.*)
		make ${ARCH_OPTS} dep || exit 1
	;;
	2.6.*)
		make ${ARCH_OPTS} prepare || exit 1
	;;
	*)
		echo "Build: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/include || exit 1
	case ${TARGET_CPU} in
	i386)
		if [ -d arch/x86 ] ;then
			( cd include >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${INSTTEMP}/usr/include/ && tar xf - )
		else
			( cd include >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${INSTTEMP}/usr/include/ && tar xf - )
		fi
	;;
	*)
		( cd include >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${INSTTEMP}/usr/include/ && tar xf - )
	;;
	esac

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