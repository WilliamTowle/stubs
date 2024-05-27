#!/bin/sh -x
# 27/03/2006

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

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

#	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
#		echo "No libssl build" 1>&2
#		exit 1
#	fi

	if [ ! -L ./install-sh ] ; then
		echo "$0: CONFIGURE: No more ./install-sh dependency :)" 1>&2
		exit 1
	else
		# *Always* point the symlinks to the versions we built (is
		# there a possibility local versions don't target correctly?)
		if [ ! -d ${FR_TH_ROOT}/usr/share/automake ] ; then
			echo "$0: CONFIGURE: No 'automake' in toolchain?" 1>&2
			exit 1
		fi
		rm ./depcomp ./install-sh ./mkinstalldirs || exit 1
		cp ${FR_TH_ROOT}/usr/share/automake/depcomp ./ || exit 1
		cp ${FR_TH_ROOT}/usr/share/automake/install-sh ./ || exit 1
		cp ${FR_TH_ROOT}/usr/share/automake/mkinstalldirs ./ || exit 1
	fi

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	  CFLAGS=${ADD_INCL_NCURSES} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile \
		  || exit 1

#	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#	cat Makefile.OLD \
#		| sed '/^CFLAGS=/ s%$%'${ADD_INCL_NCURSES}'%' \
#		> Makefile || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/bin || exit 1
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
