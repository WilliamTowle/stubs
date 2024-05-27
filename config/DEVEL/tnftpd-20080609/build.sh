#!/bin/sh
# 03/01/2005

#TODO:- build failure re SO_SNDLOWAT

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	20080609)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --without-pam \
			  || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done || exit 1

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
