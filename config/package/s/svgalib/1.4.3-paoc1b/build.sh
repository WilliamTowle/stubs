#!/bin/sh
# 22/08/2006

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

	if [ ! -x ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
		echo "$0: Aborting - no 'fakeroot'" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/vga.h ] ; then
		echo "$0: CONFIGURE: No vga.h (svgalib tc prebuild)" 1>&2
		exit 1
	fi

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		cd ${PKGNAME}-${PKGVER} || exit 1
		case ${PKGVER} in
		1.4.3)
			for PF in ../${PKGNAME}*patch ; do
				cat ${PF} | patch -Np1 -i - || exit 1
			done
#		for PF in ../${PKGNAME}*diff.gz ; do
#			zcat ${PF} | patch -Np1 -i - || exit 1
#		done
		;;
		*)
			echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
			exit 1
		;;
		esac
	fi

	[ -r Makefile.cfg.OLD ] \
		|| mv Makefile.cfg Makefile.cfg.OLD || exit 1
	cat Makefile.cfg.OLD \
		| sed '/^INCLUDE_FBDEV_DRIVER/ s/^/#/' \
		| sed '/^prefix/ s%/usr/local%%' \
		| sed '/^INSTALLMAN/ s/^/#/' \
		> Makefile.cfg || exit 1

	# setting 'CC' doesn't work
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	CC/ s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^install:/	s/uninstall//' \
			| sed 's%@ldconfig%-'${TCTREE}'/usr/sbin/ldconfig%' \
			> ${MF} || exit 1
	done

# BUILD...
	# having edited Makefile.cfg, we should:
	make clean || exit 1

	# libs: 'shared' and 'static'
	# 'installutils' requires 'textutils' and 'lrmi'
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make \
		  CC=${FR_CROSS_CC} TOPDIR=/ \
		  shared static \
		  textutils lrmi \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/etc || exit 1
	${FR_TH_ROOT}/usr/bin/fakeroot \
		-- make TOPDIR=${INSTTEMP}/ installconfig \
		  || exit 1
	${FR_TH_ROOT}/usr/bin/fakeroot \
		-- make TOPDIR=${INSTTEMP}/usr \
		  installheaders \
		  installsharedlib installstaticlib \
		  installutils installman \
		  || exit 1

	case ${PKGVER} in
	1.4.3)	# GUESSWORK based on 1.9.18
		# set a sensible mouse device and graphics mode
		mv ${INSTTEMP}/etc/vga/libvga.config ${INSTTEMP}/etc/vga/libvga.config.default || exit 1
		cat ${INSTTEMP}/etc/vga/libvga.config.default \
			| sed '/^mouse/ s/[A-Za-z]*$/PS2/' \
			| sed '/^mdev/	s/ttyS0.*/psaux/' \
			| sed '/640x480/ s/^# modeline/modeline/' \
			| sed '/800x600/ s/^# modeline/modeline/' \
			| sed '/1024x768/ s/^# modeline/modeline/' \
			> ${INSTTEMP}/etc/vga/libvga.config || exit 1

		${FR_TH_ROOT}/usr/bin/fakeroot \
			mkdir -p ${INSTTEMP}/dev \
			|| exit 1
#		${FR_TH_ROOT}/usr/bin/fakeroot \
#			mknod ${INSTTEMP}/dev/mem c 1 1 \
#			|| exit 1
	;;
	1.9.18|1.9.21)
		# set a sensible mouse device and graphics mode
		mv ${INSTTEMP}/etc/vga/libvga.config ${INSTTEMP}/etc/vga/libvga.config.default || exit 1
		cat ${INSTTEMP}/etc/vga/libvga.config.default \
			| sed '/^mouse/ s/Microsoft/PS2/' \
			| sed '/mdev/	s/^# //' \
			| sed '/^mdev/	s/ttyS0/psaux/' \
			| sed '/640x480/ s/^# modeline/modeline/' \
			> ${INSTTEMP}/etc/vga/libvga.config || exit 1
	;;
	1.9.2[345])
		# set the unconfigured mouse device, and sane graphics mode
		mv ${INSTTEMP}/etc/vga/libvga.config ${INSTTEMP}/etc/vga/libvga.config.default || exit 1
		cat ${INSTTEMP}/etc/vga/libvga.config.default \
			| sed '/^mouse/ s/unconfigured/none/' \
			| sed '/^mdev/	s/ttyS0/psaux/' \
			| sed '/640x480/ s/^# modeline/modeline/' \
			| sed '/^Helper/ s/^/#/' \
			| sed '/^# NoHelper/ s/# //' \
			> ${INSTTEMP}/etc/vga/libvga.config || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		cd ${PKGNAME}-${PKGVER} || exit 1
		case ${PKGVER} in
		1.4.3)
			for PF in ../${PKGNAME}*patch ; do
				cat ${PF} | patch -Np1 -i - || exit 1
			done
#		for PF in ../${PKGNAME}*diff.gz ; do
#			zcat ${PF} | patch -Np1 -i - || exit 1
#		done
		;;
		*)
			echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
			exit 1
		;;
		esac
	fi

	case ${PKGVER} in
	1.4.3)
		[ -r Makefile.cfg.OLD ] \
			|| mv Makefile.cfg Makefile.cfg.OLD || exit 1
		cat Makefile.cfg.OLD \
			| sed '/^INCLUDE_FBDEV_DRIVER/ s/^/#/' \
			| sed '/^prefix/ s%/usr/local%%' \
			| sed '/^INSTALLMAN/ s/^/#/' \
			| sed '/^INSTALL_/ s/-o root//' \
			| sed '/^INSTALL_/ s/-g bin//' \
			> Makefile.cfg || exit 1
	;;
	1.9.18|1.9.21|1.9.2[345])
		[ -r Makefile.cfg.OLD ] \
			|| mv Makefile.cfg Makefile.cfg.OLD || exit 1
		cat Makefile.cfg.OLD \
			| sed '/^INCLUDE_FBDEV_DRIVER/ s/^/#/' \
			| sed '/^prefix/ s%/usr/local%%' \
			| sed '/^INSTALLMAN/ s/^/#/' \
			| sed '/^INSTALL_/ s/-[og] root//g' \
			| sed '/^INSTALL_/ s/-g bin//' \
			> Makefile.cfg || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	# setting 'CC' doesn't work
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	CC/ s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^install:/	s/uninstall//' \
			| sed 's%@ldconfig%-'${TCTREE}'/usr/sbin/ldconfig%' \
			> ${MF} || exit 1
	done

# BUILD...
	# having edited Makefile.cfg, we should:
	make clean || exit 1
	# ...and then we build with 'make install'. Dirty.

	# libs: 'shared' and 'static'
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make \
		  CC=${FR_CROSS_CC} TOPDIR=${FR_LIBCDIR} \
		  shared static \
		  || exit 1

# INSTALL...
	mkdir -p ${FR_LIBCDIR}/etc || exit 1
	mkdir -p ${FR_LIBCDIR}/man || exit 1
#	make TOPDIR=${FR_LIBCDIR}/ \
#		installheaders installconfig \
#		installsharedlib installstaticlib \
#		|| exit 1
	make TOPDIR=${FR_LIBCDIR}/ \
		installheaders \
		installsharedlib installstaticlib \
		|| exit 1

#	echo "*** NB *** needs /dev/svga node ***"
#	echo "... character device, maj=209 min=0"
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
