#!/bin/sh -x
# 2008-02-02 (prev 2007-05-21)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER}-${TARGET_CPU} in
	2.0.*-i386)
		sed 's%</dev/tty%%' scripts/Configure > scripts/Configure.auto || exit 1
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' s%scripts/Configure%scripts/Configure.auto% ' > Makefile || exit 1
	;;
	2.[24].*-i386)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^HOSTCC[ 	]=/	s%gcc%'${FR_HOST_CC}'%' \
			> Makefile || exit 1
		[ -r arch/i386/boot/Makefile.OLD ] || mv arch/i386/boot/Makefile arch/i386/boot/Makefile.OLD || exit 1
		cat arch/i386/boot/Makefile.OLD \
			| sed '/^..86[ 	]=/	s%$(CROSS_COMPILE)%'${FR_TH_ROOT}'/usr/bin/%' \
			> arch/i386/boot/Makefile || exit 1
	;;
	2.6.*-i386)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^HOSTCC[ 	]=/	s%gcc%'${FR_HOST_CC}'%' \
			> Makefile || exit 1
	;;
	2.6.*-mips*) ;;
	*)
		echo "[CONFIGURE] VERSION/TARGET_CPU '${PKGVER}'/'${TARGET_CPU}'" 1>&2
		exit 1
	;;
	esac

	make ${LXSOURCE_ARCH_OPTS} \
		  mrproper \
		  include/linux/version.h \
		  symlinks || exit 1
	touch include/linux/autoconf.h || exit 1

	# we made a configuration when sanitc-lx-headers built:
	cp ${PKG_ETCDIR}/linux-${PKGVER}-config .config

	yes '' | make ${LXSOURCE_ARCH_OPTS} oldconfig || exit 1
}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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
