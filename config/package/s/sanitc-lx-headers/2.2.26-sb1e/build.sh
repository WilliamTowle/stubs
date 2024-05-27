#!/bin/sh -x
# 2007-08-04 (prev 2007-03-15)

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
		sed 's%dev/tty%dev/stdin%' scripts/Configure > scripts/Configure.auto || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
		cat Makefile.OLD \
			| sed	' /^HOSTCC/	s%gcc%'${FR_HOST_CC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$$//'`'" ; fi)% ; /^	/ s%scripts/Configure%scripts/Configure.auto% ' \
			> Makefile || exit 1

		sed	' /^CONFIG_M.86/	s/^/# / ; /CONFIG_M386/		s/^# // ; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' arch/i386/defconfig > .config || exit 1
	;;
	i386-2.2.26)
		cat arch/${TARGET_CPU}/defconfig \
			| sed	'/^CONFIG_M.86/		s/^/# /' \
			| sed	'/CONFIG_M386/		s/^# // ' \
			| sed	'/CONFIG_APM/		s/^# // ' \
			| sed	'/CONFIG_AFFS_FS[= ]/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_LOOP[= ]/	s/^# //' \
			| sed	'/CONFIG_BLK_DEV_RAM[= ]/	s/^# //' \
			| sed	'/^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' \
			> .config
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
#	i386-2.4.*)
#		sed	' /CONFIG_MPENT*/	s/^/# / ; /CONFIG_M386/		s/^# // ; /^CONFIG.*not set/	s/ is not set/=y/ ; /^#.*=y/		s/=y/ is not set/ ' arch/i386/defconfig > .config || exit 1
#	;;
#	mips-2.4.x)
#		cp arch/mips/defconfig-ip22 .config || exit 1
#	;;
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
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_LIBCDIR}/src/linux
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	PHASE=th do_configure || exit 1

# BUILD...
	make dep || exit 1


# INSTALL...
	mkdir -p ${FR_LIBCDIR}/include
	( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )

	# uClibc 0.9.26 needs the kernel Makefile
	mkdir -p ${FR_KERNSRC}
	( cd `dirname ${FR_KERNSRC}` && ln -sf linux-${PKGVER} linux ) || exit 1
	tar cvf - ./ | ( cd ${FR_KERNSRC} && tar xvf - )
}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_LIBCDIR}/src/linux
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

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
