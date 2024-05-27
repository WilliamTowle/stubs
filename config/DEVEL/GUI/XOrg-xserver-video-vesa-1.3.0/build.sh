#!/bin/sh
# 2008-06-01

#TODO: "cannot check for file existence when cross compiling" - /usr/share/X11/sgml/defs.ent

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	if [ ! -r ${FR_LIBCDIR}/include/X11/X.h ] ; then
#		echo "$0: X.h missing (build xorg-x11proto-core)" 1>&2
#		exit 1
#	fi
#
#	if [ ! -r ${FR_LIBCDIR}/include/pixman-1/pixman.h ] ; then
#		echo "$0: pixman.h missing (build [lib]pixman)" 1>&2
#		exit 1
#	else
#		ADD_INCL_PIXMAN='-I'${FR_LIBCDIR}'/include'
#	fi

	case ${PKGVER} in
	1.0.1)
		CC=${FR_CROSS_CC} \
		  ac_cv_sys_linker_h=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
#		  ac_cv__usr_share_X11_sgml_defs_ent=no \
#			  --without-linuxdoc \
	;;
	1.2.0)
		ac_cv_file__usr_share_sgml_X11_defs_ent=no \
		  CC=${FR_CROSS_CC} \
		  ac_cv_sys_linker_h=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
#			  --without-linuxdoc \
	;;
	1.4)
#	http://rene.rebe.name/2007-04-29/faq-where-has-k-drive-aka-tinyx-gone/
#	--enable-kdrive --disable-dri --disable-xorg --disable-xorgcfg
		CC=${FR_CROSS_CC} \
		  ac_cv_file__usr_share_sgml_X11_defs_ent=no \
		  PIXMAN_CFLAGS=${ADD_INCL_PIXMAN} PIXMAN_LIBS=' ' \
		  XSERVERCFLAGS_CFLAGS=' ' XSERVERCFLAGS_LIBS=' ' \
		  XSERVERLIBS_CFLAGS=' ' XSERVERLIBS_LIBS=' ' \
			./configure --prefix=/usr \
			  --host=`uname -m`-misc-linux-gnu --build=${TARGET_CPU}-uclibc-linux \
			  --disable-dri \
			  --enable-kdrive \
			  --disable-xorg \
			  --disable-xorgcfg \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# BUILD...
	case ${PKGVER} in
	1.0.1|1.2.0)
		#make || exit 1
		# http://lists.freedesktop.org/archives/xorg/2004-October/003982.html
		make World CROSSCOMPILEDIR=${FR_LIBCDIR} || exit 1
	;;
	1.4)
		#make || exit 1
		# http://lists.freedesktop.org/archives/xorg/2004-October/003982.html
		#make World CROSSCOMPILEDIR=${FR_LIBCDIR} || exit 1
		make \
		  PIXMAN_CFLAGS=${ADD_INCL_PIXMAN} PIXMAN_LIBS=' ' \
		  || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

#	make CC=${FR_HOST_CC} BOOTSTRAPCFLAGS="-I../../include" World 2>&1 | tee world.log || exit 1
##	( cd config/imake && make CC=${FR_HOST_CC} CFLAGS="-I../../include" imake ) || exit 1
##
##	rm -rf `find ./ -name "*.[oa]"`
##	make World 2>&1 | tee world.log || exit 1

# INSTALL...
	case ${PKGVER} in
	1.0.1|1.2.0)
		make DESTDIR=${INSTTEMP} install 2>&1 | tee install.log \
			|| exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
