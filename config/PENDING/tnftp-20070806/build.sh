#!/bin/sh
# 13/05/2005

#TODO:- 2.0beta1 can't load "libncurses.so.5"

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
	  ac_cv_func_getpgrp_void=yes \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile \
		  || exit 1

	mv config.h config.h.OLD || exit 1
	cat config.h.OLD \
		| sed	' /define HAVE_TERMCAP_H/	s/ 1//
			; /define HAVE_TERMCAP_H/	s/define/undef/
			' > config.h || exit 1

#echo "ADD: --${ADD_LIBC_NCURSES}--"
	mv src/Makefile src/Makefile.OLD || exit 1
	cat src/Makefile.OLD \
		| sed "/^LIBS/	s%-ltermcap%${ADD_LIBC_NCURSES}%" \
		> src/Makefile || exit 1
#		| sed '/^LIBS/	s/-ltermcap/-lncurses/' \

	mv libnetbsd/Makefile libnetbsd/Makefile.OLD || exit 1
	cat libnetbsd/Makefile.OLD \
		| sed '/^OBJS/	s/$/ err.o timegm.o/' \
		> libnetbsd/Makefile || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
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
