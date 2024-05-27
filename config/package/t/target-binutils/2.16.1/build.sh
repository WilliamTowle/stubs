#!/bin/sh
# 07/11/2004

#TODO:- when consistent ... ac_cv_path_install=${FR_TH_ROOT}/usr/bin/install
#TODO:- doesn't yet use FR_LIBCDIR

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_th()
{
# CONFIGURE...
	if [ -d ${TCTREE}/host-utils ] ; then
		FR_TH_ROOT=${TCTREE}/host-utils
		FR_TC_ROOT=${TCTREE}/cross-utils
	else
		FR_TH_ROOT=${TCTREE}
		FR_TC_ROOT=${TCTREE}
	fi
	if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
		FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc

	# host-binutils sets --{host,with-sysroot,with-lib-path}
	# host-binutils also has --host= and --enable-shared
	CC=${FR_HOST_CC} \
	  bfd_cv_has_long_long=no \
		./configure -v \
		  --prefix=${FR_TC_ROOT}/${FR_UCPATH} \
		  --target=${TARGET_CPU}-uclibc-linux-gnu \
		  --disable-largefile --disable-nls \
		  || exit 1

#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/-g //' \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	exit 1
	;;
esac
