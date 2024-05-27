#!/bin/sh
# 2008-08-15

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	make ${LXSOURCE_ARCH_OPTS} mrproper || exit 1
	# use the configuration that sanitc-lx-headers built:
	cp ${PKG_ETCDIR}/linux-${PKGVER}-config .config

	case "${PKGVER}" in
	2.[04].*)
		yes '' | make ${LXSOURCE_ARCH_OPTS} symlinks oldconfig dep || exit 1
	;;
	2.2.26)
		yes '' | make ${LXSOURCE_ARCH_OPTS} symlinks oldconfig dep || exit 1
		touch include/linux/autoconf.h
 	;;
#	#2.4.x untested
#	2.4.*)
#		yes '' | make ${LXSOURCE_ARCH_OPTS} symlinks oldconfig || exit 1
# 	;;
	2.6.*)
		yes '' | make ${LXSOURCE_ARCH_OPTS} oldconfig archprepare || exit 1
	;;
	*)
		echo "Unexpected VERSION/TARGET_CPU '${PKGVER}'/'${TARGET_CPU}'" 1>&2
		exit 1
 	;;
	esac
}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -d ${FR_KERNSRC} ] ; then
		echo "No KTREE ${FR_KERNSRC} (linux-${PKGVER})" 1>&2
		exit 1
	else
		( cd ${FR_KERNSRC} >/dev/null || exit 1
			tar cvf - Makefile
		) | tar xvf -
	fi

	if [ ! -r ${FR_TH_ROOT}/bin/bash ] ; then
		echo "$0: No _TH_ROOT /bin/bash" 1>&2
		exit 1
	fi

	PKG_ETCDIR=${TCTREE}/etc/${USE_TOOLCHAIN}
	case ${TARGET_CPU} in
	mipsel)
		LXSOURCE_ARCH_OPTS=ARCH=mips
	;;
	*)
		LXSOURCE_ARCH_OPTS=ARCH=${TARGET_CPU}
	;;
	esac

	LXSOURCE_BUILD_OPTS="${LXSOURCE_ARCH_OPTS} CROSS_COMPILE="`echo ${FR_CROSS_CC} | sed 's/senban/kernel/ ; s/gcc$//'`" CONFIG_SHELL=${FR_TH_ROOT}/bin/bash"

	do_configure || exit 1

# BUILD...
	case ${PKGVER}-${TARGET_CPU} in
#	2.0.*-*)
#		rm scripts/mkdep >/dev/null 2>&1
#		make HOSTCC=${GCC2723} dep || exit 1
#		for TGT in modules bzImage ; do
#			make CC="${GCC2723} -D__KERNEL__ -nostdinc -I"`pwd`"/include -I${GCC2723INC}" CFLAGS='-O2 -fomit-frame-pointer' $${TGT} || exit 1
#		done || exit 1
#	;;
	*-i386)
		make ${LXSOURCE_BUILD_OPTS} bzImage || exit 1
	;;
	*-*)
		make ${LXSOURCE_BUILD_OPTS} || exit 1
	;;
	esac

# INSTALL...
	case ${TARGET_CPU} in
	i386)
		cp arch/i386/boot/bzImage ${PKG_ETCDIR}/vmlinuz-${PKGVER} || exit 1
	;;
	*)
		cp vmlinux ${PKG_ETCDIR}/vmlinux-${PKGVER} || exit 1
	;;
	esac
}

case "$1" in
#distro-cross)
#	make_build || exit 1
#;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Bad COMMAND $1" 1>&2
	exit 1
;;
esac
