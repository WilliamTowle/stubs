#!/bin/sh
# 12/08/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

#make_dc()
#{
#}

make_th()
{
# CONFIGURE...

#	if [ ! -d ${TCTREE}/usr/src/linux-${PKGVER} ] ; then
#		echo "No [TC]/usr/src tree" 1>&2
#		exit 1
#	else
#		( cd ${TCTREE}/usr/src/linux-${PKGVER} \
#			&& tar cvf - include/linux/autoconf.h ) \
#			| tar xvf -
#	fi

	[ -r Makefile.OLD ] || cp Makefile Makefile.OLD || exit 1
	case ${PKGVER} in
	2.0.40-rc6*)	# ...2.0.40-rc6 patch still thinks it's -rc5
		cat Makefile.OLD \
			| sed '/^EXTRAVERSION/ s/-rc5/-rc6/' \
			| sed 's%echo sh%echo '${TCTREE}'/bin/bash%' \
			> Makefile || exit 1
		;;
	*)
		cat Makefile.OLD \
			| sed 's%echo sh%echo '${TCTREE}'/bin/bash%' \
			> Makefile || exit 1
		;;
	esac \
		|| exit 1 

# BUILD/INSTALL...
	if [ ! -d ${TCTREE}/etc/${USE_DISTRO} ] ; then
		echo "No ${TCTREE}/etc/${USE_DISTRO}! Did you build linux2.0source?" 1>&2
		exit 1
	fi

	for TWEAK in apm noapm ; do
		CONFIG=${TCTREE}/etc/${USE_DISTRO}/config-lx${PKGVER}-${TWEAK}
		[ -r ${CONFIG} ] || CONFIG=${TCTREE}/etc/${USE_DISTRO}/config-lx`echo ${PKGVER} | sed 's/\.//g'`-${TWEAK}

		cp ${CONFIG} .config || exit 1
		( yes "" | make oldconfig ) || exit 1

		rm scripts/mkdep >/dev/null 2>&1
		if [ -r ${TCTREE}/usr/host-linux/bin/gcc ] ; then
			make HOSTCC=${TCTREE}/usr/host-linux/bin/gcc dep || exit 1
		else
			make HOSTCC=`which gcc` dep || exit 1
		fi

		if [ -L `which find` ] ; then
			# busybox 'find' won't `make clean`...
			rm -rf `find ./ -name "*.[ao]"`
		else
			make clean || exit 1
		fi

		if [ -r ${TCTREE}/usr/kgcc-2.7.2.3 ] ; then
			COMPILER=${TCTREE}/usr/kgcc-2.7.2.3/bin/${TARGET_CPU}-linux-gcc
			GCCINCDIR=`${COMPILER} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`
			INCLS="-nostdinc -I`pwd`/include -I${GCCINCDIR}"
		else
			# settings
			COMPILER=${TCTREE}/usr/bin/${TARGET_CPU}-linux-gcc
			INCLS="-nostdinc -I`pwd`/include -I${TCTREE}/usr/lib/gcc-lib/${TARGET_CPU}-linux/2.7.2.3/include"
		fi
		if [ ! -r ${COMPILER} ] ; then
			echo "Akk - no COMPILER ${COMPILER}"
			exit 1
		fi

		for TARGET in modules bzImage ; do
			make CC="${COMPILER} -D__KERNEL__ ${INCLS}" \
				CFLAGS="-O2 -fomit-frame-pointer" \
				${TARGET} || exit 1
		done || exit 1

		cp arch/${TARGET_CPU}/boot/bzImage ${TCTREE}/etc/${USE_DISTRO}/vmlinuz-${PKGVER}-${TWEAK} || exit 1

		#make modules_install || exit 1
		mkdir -p ${TCTREE}/etc/${USE_DISTRO}/modules/${PKGVER}-${TWEAK} || exit 1
		( cd drivers && tar cvf - */*.o ) | ( cd ${TCTREE}/etc/${USE_DISTRO}/modules/${PKGVER}-${TWEAK} && tar xvf - )
	done || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
