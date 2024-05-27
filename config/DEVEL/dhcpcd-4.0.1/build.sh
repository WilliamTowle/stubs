#!/bin/sh -x
# from INCOMING 2008-04-04

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/MK=/ s%^%CC='${FR_CROSS_CC}'\n\n%' \
		> Makefile || exit 1

	[ -r mk/cc.mk.OLD ] || mv mk/cc.mk mk/cc.mk.OLD || exit 1
	cat mk/cc.mk.OLD \
		| sed '/C99/,/_CSTD_SH/ s/^/#/' \
		> mk/cc.mk || exit 1
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

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

	if [ -r ./configure ] ; then
		echo "./configure found"
		exit 1
#	CC=${FR_CROSS_CC} \
#	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
#		  --disable-nls \
#		  --with-included-regex \
#		  || exit 1
	fi

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
