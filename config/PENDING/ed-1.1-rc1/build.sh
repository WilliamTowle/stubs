#!/bin/sh
# 2007-08-25

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PHASE} in
	dc)
		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /^CC[ 	]*/ s%g*cc%'${FR_CROSS_CC}'%
					; /^CFLAGS/ s/ -g //' \
				> ${MF} || exit 1
		done
	;;
	th)
		CC=${FR_HOST_CC} \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/ -g //' \
				> ${MF} || exit 1
		done
	;;
	*)
		echo "do_configure: Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure

# BUILD...

	make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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
