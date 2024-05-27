#!/bin/sh -x
# 2008-06-01

#TODO: "cannot check for file existence when cross compiling" - /usr/share/X11/sgml/defs.ent

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
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
			  --disable-xorg \
			  --disable-xorgcfg \
			  --enable-kdrive --enable-kdrive-vesa \
			  --disable-dri \
			  --disable-dpms \
			  --disable-shm \
			  --disable-xf86bigfont \
			  --disable-xinerama \
			  --disable-xvfb --disable-mfb --disable-cfb --disable-afb --disable-xfbdev \
			  --disable-screensaver --disable-xv --disable-xvmc --disable-xres \
			  --disable-xdm-auth-1 \
			  --disable-xevie \
			  --disable-xdmcp \
			  || exit 1

		[ -r include/miscstruct.h.OLD ] || mv include/miscstruct.h include/miscstruct.h.OLD
		cat include/miscstruct.h.OLD \
			| sed 's%<pixman.h>%<pixman-1/pixman.h>%' \
			> include/miscstruct.h

		for SF in mi/mifpoly.h mi/miarc.c mi/miregion.c ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's/_X_INLINE//' \
				> ${SF} || exit 1
		done

		[ -r os/utils.c.OLD ] || mv os/utils.c os/utils.c.OLD || exit 1
		cat os/utils.c.OLD \
			| sed '/CoreDump = TRUE;/,+6 { s/CoreDump = TRUE;// ; s/endif/endif\nCoreDump= TRUE;/ }' \
			> os/utils.c || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/X11/X.h ] ; then
		echo "$0: X.h missing (build xorg-x11proto-core)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/pixman-1/pixman.h ] ; then
		echo "$0: pixman.h missing (build [lib]pixman)" 1>&2
		exit 1
	else
		ADD_INCL_PIXMAN='-I'${FR_LIBCDIR}'/include/pixman-1'
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/fonts/font.h ] ; then
		echo "$0: font.h missing (build xorg-x11proto-fonts)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/XI.h ] ; then
		echo "$0: XI.h missing (build xorg-x11proto-input)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/XKBstr.h ] ; then
		echo "$0: XKBstr.h missing (build xorg-x11proto-kb)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/renderproto.h ] ; then
		echo "$0: renderproto missing (build xorg-x11proto-render)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/xcmiscstr.h ] ; then
		echo "$0: xcmiscstr missing (build xorg-x11proto-xcmisc)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/Xauth.h ] ; then
		echo "$0: Xauth.h missing (build libxau)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/shmstr.h ] ; then
		echo "$0: shmstr.h missing (build xorg-x11proto-xext)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/bigreqstr.h ] ; then
		echo "$0: bigreqstr.h missing (build xorg-x11proto-bigreqs)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/Xdmcp.h ] ; then
		echo "$0: X11/Xdmcp.h missing (build libxdmcp)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/Xtrans/Xtrans.h ] ; then
		echo "$0: X11/Xtrans/Xtrans.h missing (build xtrans)" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/X11/extensions/randr.h ] ; then
		echo "$0: X11/extensions/randr.h missing (build libxrandr)" 1>&2
		exit 1
	fi

	PHASE=dc do_configure || exit 1

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
		CFLAGS=${ADD_INCL_PIXMAN} \
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
