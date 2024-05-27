#!/bin/sh
# 2008-05-26 (prev 2007-11-19)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	7.0.4)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
			> Makefile || exit 1
	;;
	7.1.1|7.1.2)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr \
			  --host=${FR_HOST_DEFN}
			  `uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
	;;
	8.0.[0134]|8.1.[12345])
		if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
			echo "$0: Aborting -- no 'fakeroot'" 1>&2
			exit 1
		fi

		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr \
			  --host=${FR_HOST_DEFN} --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	7.0.4)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make REQUIRE_NLS='' \
			  CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  || exit 1
	;;
	7.1.1|7.1.2)
		make || exit 1
	;;
	8.0.[0134]|8.1.[12345])
		make || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	7.0.4)
		mkdir -p ${INSTTEMP}/var/log/sa || exit 1
		make DESTDIR=${INSTTEMP} IGNORE_MAN_GROUP=y REQUIRE_NLS='' \
		  install || exit 1
	;;
	7.1.1|7.1.2)
		make DESTDIR=${INSTTEMP} install \
	;;
	8.0.[0134]|8.1.[12345])
		${FR_TH_ROOT}/usr/bin/fakeroot \
			-- make DESTDIR=${INSTTEMP} install
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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
