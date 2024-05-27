#!/bin/sh
# 2005-12-07

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  bash_cv_have_mbstate_t=yes \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile \
		  || exit 1

	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/ -g //' \
			> ${MF} || exit 1
	done

# BUILD...
	make || exit 1

# INSTALL...
	make prefix=${FR_LIBCDIR} install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
