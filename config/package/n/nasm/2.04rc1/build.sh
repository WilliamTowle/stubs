#!/bin/sh
# 2008-10-19 (prev 2007-01-22)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

## 'autoconf' causes 'configure' rebuild (recommended for CVS sources)
#	autoconf

	case ${PHASE} in
	th)
		CC=${FR_HOST_CC} \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  || exit 1
	;;
	dc)
		CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
	;;
	*)
		echo "$0: Unexpected ARG '$1'" 1>&2
		exit 1
	;;
	esac

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/ *-g */ /' \
			| sed '/^CFLAGS/ s/ *-std=c99 */ /' \
			> ${MF} || exit 1
	done || exit 1
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure

# BUILD...
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin ${INSTTEMP}/usr/man/man1
	make prefix=${INSTTEMP}/usr install || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

	PHASE=th do_configure

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
