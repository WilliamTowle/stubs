#!/bin/sh
# 07/01/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ ! -r ${FR_LIBCDIR}/include/lzo/lzoconf.h ] ; then
		echo "No lzoconf.h" 1>&2
		exit 1
	else
		ADD_INCL_LZO='-I'${FR_LIBCDIR}'/include/lzo'
		ADD_LIB_LZO='-L'${FR_LIBCDIR}'/lib'
	fi

	[ -r configure.OLD ] || mv configure configure.OLD || exit 1
	cat configure.OLD \
		| sed '/LIBS=/ s/-llzo/-llzo2/' \
		> configure || exit 1
	chmod a+x configure || exit 1

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_LZO}" \
	  CPPFLAGS="${ADD_INCL_LZO}" \
	  LDFLAGS="${ADD_LIB_LZO}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1

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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
