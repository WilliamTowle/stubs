#!/bin/sh -x
# 2008-06-22

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/event.h ] ; then
		echo "$0: Aborting - no 'libevent' built" 2>&1
		exit 1
	fi

	if [ ! -d ${FR_LIBCDIR}/include/err_h ] ; then
		echo "No Kragen's err.h build" 1>&2
		exit 1
	else
		DIR_KRAGENSERRH=${FR_LIBCDIR}/include/err_h
		ADD_INCL_KRAGENSERRH=-I${DIR_KRAGENSERRH}
		ADD_LIBS_KRAGENSERRH=-lerr
	fi

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_KRAGENSERRH}" \
	  LDFLAGS="${ADD_LIBS_KRAGENSERRH}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls \
		  --with-included-regex \
		  --with-libevent=${FR_LIBCDIR} \
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
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
