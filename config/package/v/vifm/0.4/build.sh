#!/bin/sh -x
# 27/03/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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

	case ${PKGVER} in
	0.3)
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

		  CC=${FR_CROSS_CC} \
		  CFLAGS=${ADD_INCL_NCURSES} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1
	;;
	*)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=${ADD_INCL_NCURSES} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-nls --disable-largefile \
			  || exit 1
	;;
	esac

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
