#!/bin/sh -x
# from INCOMING 2008-04-04

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

#	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
#		echo "No libssl build" 1>&2
#		exit 1
#	fi

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  || exit 1

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LIBC_NCURSES} || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
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
