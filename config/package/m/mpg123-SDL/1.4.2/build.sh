#!/bin/sh
# 2008-04-11

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
	  SDL_CFLAGS="${ADD_INCL_SDL}" \
	  SDL_LIBS="${ADD_LDFLAGS_SDL}" \
	  ac_cv_func_setpriority=no \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --with-audio=sdl \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -d ${FR_LIBCDIR}/usr/include/SDL ] ; then
		ADD_INCL_SDL='-I'${FR_LIBCDIR}'/usr/include/SDL/'
		ADD_LDFLAGS_SDL='-L'${FR_LIBCDIR}'/usr/lib -lSDL'
	else
		echo "$0: Confused -- no SDL built" 1>&2
		exit 1
	fi

	PHASE=dc do_configure || exit 1

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
