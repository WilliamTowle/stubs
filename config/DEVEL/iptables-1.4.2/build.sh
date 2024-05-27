#!/bin/sh
# 16/07/2005

#TODO:- presently failing on kernel source specification
#TODO:- build fails (...due to lack of netfilter/IPv6 in kernel)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	1.3.4)
		if [ ! -d ${FR_KERNSRC} ] ; then
			echo "$0: Configure: Bad FR_KERNSRC ${FR_KERNSRC}" 1>&2
			exit 1
		fi

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^KERNEL_DIR/ s%/usr.*%'${FR_KERNSRC}'%' \
				> ${MF} || exit 1
		done
	;;
	1.4.1.1|1.4.2)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure \
			  --host=${FR_HOST_DEFN} --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  || exit 1
#			  --without-included-regex 
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	1.3.4)
		make CC=${FR_CROSS_CC} \
		  KERNEL_DIR=${FR_KERNSRC} \
		  || exit 1
	;;
	1.4.1.1|1.4.2)
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
