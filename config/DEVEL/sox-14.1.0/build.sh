#!/bin/sh
# 2008-08-09

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	12.18.2)
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
	;;
	13.0.0|14.1.0)
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=${FR_HOST_DEFN} --build=${FR_TARGET_DEFN} \
			  || exit 1
	;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	12.17.7|12.17.8|12.17.8.1|12.18.1|12.18.2)
		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/ -g //' \
				| sed 's%/usr$%${DESTDIR}/usr%' \
				> ${MF} || exit 1
		done || exit 1
	;;
	13.0.0|14.1.0)
		# (v13.0.0) tries to run (cross-compiled) ./sox :(
		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/ -g //' \
				| sed '/--help/	s/^/#/' \
				> ${MF} || exit 1
		done || exit 1
	;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make || exit 1

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
