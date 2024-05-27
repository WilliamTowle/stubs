#!/bin/sh
# 26/01/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...

# BUILD...

# INSTALL...
	case ${PKGVER} in
	1.7.3)
		mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
		for SCRIPT in ff fl ; do
			cp ${SCRIPT} ${INSTTEMP}/usr/local/bin || exit 1
			chmod a+x ${INSTTEMP}/usr/local/bin/${SCRIPT} || exit 1
		done
	;;
	2.1|2.2)
		mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
		cp ff.bash ${INSTTEMP}/usr/local/bin/ || exit 1
		mkdir -p ${INSTTEMP}/usr/local/ff-bash || exit 1
		cp -r lib/* examples/* ${INSTTEMP}/usr/local/ff-bash/ || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
