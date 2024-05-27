#!/bin/sh
# 22/03/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_prepare_212()
{
	# v2.12[a-r] has an 'MCONFIG' file out of the box
	[ -r MCONFIG.OLD ] || mv MCONFIG MCONFIG.OLD || exit 1
	case ${PHASE} in
	dc)
		grep -v _FILE_OFFSET_BITS MCONFIG.OLD \
			| sed 's/uname -m/echo '${TARGET_CPU}'/' \
			| sed 's/ -o root//' \
			> MCONFIG || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^	hwclock/ s/hwclock //' \
				| sed '/^	mount/ s/mount //' \
				| sed 's/ mkswap / /' \
				| sed 's/ mkswap.8 / /' \
				> ${MF} || exit 1
		done
	;;
	th)
		grep -v _FILE_OFFSET_BITS MCONFIG.OLD \
			| sed 's/ -o root//' \
			> MCONFIG || exit 1
	;;
	esac
}

do_configure_213()
{
	case ${PHASE}-${PKGVER} in
	th*)
		echo "Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	dc-2.13-pre[24])
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1

		[ -r disk-utils/Makefile.OLD ] || mv disk-utils/Makefile disk-utils/Makefile.OLD || exit 1
		cat disk-utils/Makefile.OLD \
			| sed '/^fsck_[A-Z]/		s/^/#/' \
			| sed '/^mkfs_[A-Z]/		s/^/#/' \
			| sed '/^mkswap_[A-Z]/		s/^/#/' \
			> disk-utils/Makefile || exit 1
	;;
	dc-2.13-pre5)
#		if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
#			echo "$0: Aborting -- no 'fakeroot'" 1>&2
#			exit 1
#		fi

#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1

		# v2.13-pre5: swapon wants 'R_OK'
		[ -r mount/Makefile.OLD ] || mv mount/Makefile mount/Makefile.OLD || exit 1
		cat mount/Makefile.OLD \
			| sed '/^swapon_[A-Z]/		s/^/#/' \
			> mount/Makefile || exit 1

		[ -r schedutils/Makefile.OLD ] || mv schedutils/Makefile schedutils/Makefile.OLD || exit 1
		cat schedutils/Makefile.OLD \
			| sed '/^taskset_[A-Z]/		s/^/#/' \
			> schedutils/Makefile || exit 1

		# v2.13-pre5: 
		for SF in disk-utils/blockdev.c disk-utils/mkfs.c \
			disk-utils/mkswap.c \
			disk-utils/fsck.minix.c disk-utils/mkfs.minix.c \
			disk-utils/fdformat.c disk-utils/isosize.c \
			fdisk/fdisk.c fdisk/sfdisk.c fdisk/cfdisk.c \
			getopt/getopt.c \
			hwclock/hwclock.c \
			login-utils/agetty.c login-utils/wall.c \
			misc-utils/ddate.c misc-utils/logger.c \
			misc-utils/mcookie.c misc-utils/namei.c \
			misc-utils/script.c misc-utils/whereis.c \
			misc-utils/rename.c \
			mount/mount.c mount/umount.c \
			mount/lomount.c mount/swapon.c \
			sys-utils/dmesg.c sys-utils/ctrlaltdel.c \
			sys-utils/cytune.c sys-utils/ipcrm.c \
			sys-utils/ipcs.c sys-utils/renice.c \
			sys-utils/setsid.c sys-utils/readprofile.c \
			sys-utils/tunelp.c \
			text-utils/col.c text-utils/colcrt.c \
			text-utils/column.c \
			text-utils/hexdump.c \
			text-utils/rev.c \
			text-utils/tailf.c \
		; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed '/setlocale[(]/	s/[(].*[)]/()/' \
				| sed '/new_broken_time *=/	s/new/memcpy(\&new/' \
				| sed '/new_broken_time *=/	s/;/, sizeof(struct tm));/' \
				| sed '/new_broken_time *=/	s/ *= *\*/, /' \
				> ${SF} || exit 1
		done
	;;
	dc-2.13-pre6)
#		if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
#			echo "$0: Aborting -- no 'fakeroot'" 1>&2
#			exit 1
#		fi

#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1

		# v2.13-pre5: swapon wants 'R_OK'
		[ -r mount/Makefile.OLD ] || mv mount/Makefile mount/Makefile.OLD || exit 1
		cat mount/Makefile.OLD \
			| sed '/^swapon_[A-Z]/		s/^/#/' \
			> mount/Makefile || exit 1

		[ -r schedutils/Makefile.OLD ] || mv schedutils/Makefile schedutils/Makefile.OLD || exit 1
		cat schedutils/Makefile.OLD \
			| sed '/^taskset_[A-Z]/		s/^/#/' \
			> schedutils/Makefile || exit 1

		# v2.13-pre5: 
		for SF in disk-utils/blockdev.c disk-utils/mkfs.c \
			disk-utils/mkswap.c \
			disk-utils/fsck.minix.c disk-utils/mkfs.minix.c \
			disk-utils/fdformat.c disk-utils/isosize.c \
			fdisk/fdisk.c fdisk/sfdisk.c fdisk/cfdisk.c \
			getopt/getopt.c \
			hwclock/hwclock.c \
			login-utils/agetty.c login-utils/wall.c \
			misc-utils/ddate.c misc-utils/logger.c \
			misc-utils/mcookie.c misc-utils/namei.c \
			misc-utils/script.c misc-utils/whereis.c \
			misc-utils/rename.c \
			misc-utils/setterm.c \
			mount/mount.c mount/umount.c \
			mount/lomount.c mount/swapon.c \
			sys-utils/dmesg.c sys-utils/ctrlaltdel.c \
			sys-utils/cytune.c sys-utils/ipcrm.c \
			sys-utils/ipcs.c sys-utils/renice.c \
			sys-utils/setsid.c sys-utils/readprofile.c \
			sys-utils/tunelp.c \
			text-utils/col.c text-utils/colcrt.c \
			text-utils/column.c \
			text-utils/hexdump.c \
			text-utils/rev.c \
			text-utils/tailf.c \
			text-utils/ul.c \
		; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed '/setlocale[(]/	s/[(].*[)]/()/' \
				| sed '/new_broken_time *=/	s/new/memcpy(\&new/' \
				| sed '/new_broken_time *=/	s/;/, sizeof(struct tm));/' \
				| sed '/new_broken_time *=/	s/ *= *\*/, /' \
				> ${SF} || exit 1
		done
	;;
	dc-2.13-pre7)
#		if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
#			echo "$0: Aborting -- no 'fakeroot'" 1>&2
#			exit 1
#		fi

		if [ ! -r ${FR_TH_ROOT}/usr/bin/autoconf ] ; then
			echo "$0: Aborting -- no 'autoconf'" 1>&2
			exit 1
		fi

		if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
			echo "$0: Failed: No zlib.h?" 1>&2
			exit 1
		fi

#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1

#		# v2.13-pre5: swapon wants 'R_OK'
#		[ -r mount/Makefile.OLD ] || mv mount/Makefile mount/Makefile.OLD || exit 1
#		cat mount/Makefile.OLD \
#			| sed '/^swapon_[A-Z]/		s/^/#/' \
#			> mount/Makefile || exit 1
#
#		[ -r schedutils/Makefile.OLD ] || mv schedutils/Makefile schedutils/Makefile.OLD || exit 1
#		cat schedutils/Makefile.OLD \
#			| sed '/^taskset_[A-Z]/		s/^/#/' \
#			> schedutils/Makefile || exit 1

#		# v2.13-pre5: LC_ALL et al
#			getopt/getopt.c \
#			hwclock/hwclock.c \
#			login-utils/agetty.c login-utils/wall.c \
#			misc-utils/ddate.c misc-utils/logger.c \
#			misc-utils/mcookie.c misc-utils/namei.c \
#			misc-utils/script.c misc-utils/whereis.c \
#			misc-utils/rename.c \
#			misc-utils/setterm.c \
#			mount/mount.c mount/umount.c \
#			mount/lomount.c mount/swapon.c \
#			sys-utils/dmesg.c sys-utils/ctrlaltdel.c \
#			sys-utils/cytune.c sys-utils/ipcrm.c \
#			sys-utils/ipcs.c sys-utils/renice.c \
#			sys-utils/setsid.c sys-utils/readprofile.c \
#			sys-utils/tunelp.c \
#			text-utils/col.c text-utils/colcrt.c \
#			text-utils/column.c \
#			text-utils/hexdump.c \
#			text-utils/rev.c \
#			text-utils/tailf.c \
#			text-utils/ul.c \
		for SF in \
			disk-utils/blockdev.c \
			disk-utils/fdformat.c \
			disk-utils/fsck.minix.c \
			disk-utils/isosize.c \
			disk-utils/mkfs.c \
			disk-utils/mkfs.minix.c \
			disk-utils/mkswap.c \
			fdisk/fdisk.c fdisk/sfdisk.c fdisk/cfdisk.c \
			mount/lomount.c \
			mount/mount.c \
			mount/swapon.c \
			mount/umount.c \
			login-utils/agetty.c \
			login-utils/simpleinit.c \
			login-utils/last.c \
			login-utils/mesg.c \
			login-utils/shutdown.c \
			login-utils/wall.c \
			login-utils/login.c \
			login-utils/chfn.c \
			login-utils/chsh.c \
			login-utils/newgrp.c \
			login-utils/vipw.c \
			misc-utils/ddate.c \
			misc-utils/kill.c \
			misc-utils/logger.c \
			misc-utils/mcookie.c \
			misc-utils/namei.c \
			misc-utils/script.c \
			misc-utils/setterm.c \
			misc-utils/whereis.c \
			misc-utils/write.c \
			misc-utils/rename.c \
			sys-utils/ctrlaltdel.c \
			sys-utils/cytune.c \
			sys-utils/dmesg.c \
			sys-utils/ipcrm.c \
			sys-utils/ipcs.c \
			sys-utils/rdev.c \
			sys-utils/readprofile.c \
			sys-utils/renice.c \
			sys-utils/setsid.c \
			sys-utils/tunelp.c \
			text-utils/col.c \
			text-utils/colcrt.c \
			text-utils/colrm.c \
			text-utils/column.c \
			text-utils/hexdump.c \
			text-utils/more.c \
			text-utils/rev.c \
			text-utils/ul.c \
			text-utils/pg.c \
			text-utils/tailf.c \
			hwclock/hwclock.c \
			getopt/getopt.c \
			lib/env.c \
		; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed '/(LC_ALL/	s/[(].*[)]/()/' \
				| sed '/(LC_NUMERIC/	s/[(].*[)]/()/' \
				> ${SF} || exit 1
#				| sed '/new_broken_time *=/	s/new/memcpy(\&new/' \
#				| sed '/new_broken_time *=/	s/;/, sizeof(struct tm));/' \
#				| sed '/new_broken_time *=/	s/ *= *\*/, /' \
		done
	;;
	*)
		echo "$0: do_configure_213(): Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

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

	case ${PKGVER} in
	2.12[a-r])
		PHASE=dc do_prepare_212 || exit 1

#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1
	;;
	2.13-pre[1-7])
		PHASE=dc do_configure_213 || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	2.12[a-r])
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make || exit 1
	;;
	2.13-pre7)
		# (22/03/2006) Need 'autoconf' to build
		PATH=${FR_TH_ROOT}/usr/bin:${PATH}
			make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# INSTALL...
	case ${PKGVER} in
	2.12[a-r])
#		PATH=${TCTREE}/bin:${PATH}
			make DESTDIR=${REMAINDER_INSTTEMP} USE_TTY_GROUP=no \
			  install \
			  || exit 1

		# directories for the "minimal" packages...
		mkdir -p ${MINIMAL_INSTTEMP} || exit 1
		# ...fully relocate /etc
		[ -d ${MINIMAL_INSTTEMP}/etc ] && rm -rf ${MINIMAL_INSTTEMP}/etc
		mv ${REMAINDER_INSTTEMP}/etc ${MINIMAL_INSTTEMP}/ || exit 1
		# ...simple `mkdir` others
		mkdir -p ${MINIMAL_INSTTEMP}/sbin || exit 1
		mkdir -p ${MINIMAL_INSTTEMP}/usr/bin || exit 1
		mkdir -p ${MINIMAL_INSTTEMP}/usr/share/man/man8 || exit 1

		( cd ${REMAINDER_INSTTEMP} &&
			for F in	usr/bin/fdformat usr/bin/setfdprm \
					sbin/fsck.minix sbin/mkfs.minix \
					sbin/fdisk ; do
				mv $F ${MINIMAL_INSTTEMP}/$F || exit 1
				mv usr/share/man/man8/`basename $F`.8 ${MINIMAL_INSTTEMP}/usr/share/man/man8/ || exit 1
			done || exit 1
		) || exit 1
	;;
	2.13-pre[56])
#		${FR_TH_ROOT}/usr/bin/fakeroot \
#			-- make DESTDIR=${REMAINDER_INSTTEMP} install || exit 1
		make DESTDIR=${REMAINDER_INSTTEMP} install || exit 1
		mkdir -p ${MINIMAL_INSTTEMP} || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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

	case ${PKGVER} in
	2.12[a-r])
		PHASE=th do_prepare_212 || exit 1

		CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=${TCTREE}/ \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	# v2.12[a-r]
	make || exit 1

# INSTALL...
	# v2.12[a-r]
	make DESTDIR=${TCTREE} USE_TTY_GROUP=no install
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
