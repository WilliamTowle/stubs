#!/bin/sh
# 05/02/2006 (prev: 29/06/2004)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

#make_dc()
#{
## CONFIGURE...
#	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
#		# Ah, sanity! 2005-11-11 onward
#		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
#	else
##		echo "$0: CONFIGURE: Configuration not determined" 1>&2
#		if [ -d ${TCTREE}/cross-utils ] ; then
#			FR_TC_ROOT=${TCTREE}/cross-utils
#			FR_TH_ROOT=${TCTREE}/host-utils
#		else
#			FR_TC_ROOT=${TCTREE}/
#			FR_TH_ROOT=${TCTREE}/
#		fi
#
#		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
#		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
#		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
#			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
#		else
#			FR_HOST_CC=`which gcc`
#		fi
#		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
#	fi
#
##	PATH=${UCPATH}/bin:${PATH}
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m`-pc-linux --build=${TARGET_CPU}-pc-linux \
#		  --disable-joystick \
#		  --enable-video-svga \
#		  || exit 1
#
## BUILD...
##	PATH=${UCPATH}/bin:${PATH}
#		make || exit 1
#
## INSTALL...
#	make DESTDIR=${INSTTEMP} install || exit 1
#}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ -r ${FR_LIBCDIR}/usr/bin/sdl-config ] ; then
		ADD_INCL_SDL='-I'${FR_LIBCDIR}'/usr/include/SDL'
		ADD_LDFLAGS_SDL='-L'${FR_LIBCDIR}'/usr/lib'
	else
		echo "$0: Confused -- no sdl-config" 1>&2
		exit 1
	fi

#	PATH=${UCPATH}/bin:${PATH}
	SDL_CONFIG=${FR_LIBCDIR}/usr/bin/sdl-config \
	  CC=${FR_CROSS_CC} \
	  CFLAGS="${ADD_INCL_SDL}" \
	  LDFLAGS="${ADD_LDFLAGS_SDL}" \
		./configure --prefix=/usr \
		  --host=`uname -m`-pc-linux --build=${TARGET_CPU}-pc-linux \
		  --disable-joystick \
		  --enable-video-svga \
		  || exit 1

# BUILD...
#	PATH=${UCPATH}/bin:${PATH}
		make || exit 1

# INSTALL...
	make DESTDIR=${FR_LIBCDIR} install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#	;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
