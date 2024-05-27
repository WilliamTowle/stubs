#!/bin/sh
# 2007-07-29 (prev. 2005-11-29)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_prepare()
{
	# v2.12[a-r] has an 'MCONFIG' file out of the box
	[ -r MCONFIG.OLD ] || mv MCONFIG MCONFIG.OLD || exit 1
	case ${PHASE} in
	dc|th)
		grep -v _FILE_OFFSET_BITS MCONFIG.OLD \
			| sed 's/uname -m/echo '${TARGET_CPU}'/' \
			| sed 's/ -o root//' \
			> MCONFIG || exit 1
	;;
	*)
		echo "$0: do_prepare(): Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	2.12[a-r])
		PHASE=dc do_prepare || exit 1

		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-nls --disable-largefile \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^	hwclock/ s/hwclock //' \
				| sed '/^	mount/ s/mount //' \
				| sed 's/ mkswap / /' \
				| sed 's/ mkswap.8 / /' \
				| sed 's/[ 	]mkfs.minix.8[ 	]/	/' \
				| sed 's/[ 	]fsck.minix.8[ 	]/	/' \
				| sed '/^SBIN[ 	]*=/ { s/mkfs.minix// ; s/fsck.minix// }' \
				> ${MF} || exit 1
		done
	;;
	2.13-pre[24])
		PATH=${FR_LIBCDIR}/bin:${PATH} \
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
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make || exit 1

# INSTALL...
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
				sbin/fdisk ; do
			mv $F ${MINIMAL_INSTTEMP}/$F || exit 1
			mv usr/share/man/man8/`basename $F`.8 ${MINIMAL_INSTTEMP}/usr/share/man/man8/ || exit 1
		done
	) || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=th do_prepare || exit 1

	CC=${FR_HOST_CC} \
	  CFLAGS=-O2 \
		./configure --prefix=${FR_TH_ROOT}/ \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make DESTDIR=${FR_TH_ROOT} USE_TTY_GROUP=no install
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
