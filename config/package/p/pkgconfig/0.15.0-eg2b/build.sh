#!/bin/sh
# 04/03/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	case ${PKGVER} in
	0.15.0)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  ac_cv_func_setresuid=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			 --disable-largefile --disable-nls \
			 || exit 1
		;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1 # else glib-1.2.8 configure will fail
		;;
	esac

	for MF in Makefile glib-1.2.8/Makefile ; do
		[ -r $MF.OLD ] || mv $MF $MF.OLD || exit 1
		cat $MF.OLD \
			| sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
			> $MF || exit 1
	done

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/usr/host-linux/bin/gcc ] ; then
		FR_HOST_CC=${TCTREE}/usr/host-linux/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	./configure --prefix=/usr \
	  --host=`uname -m` --build=${TARGET_CPU} \
	  --disable-largefile --disable-nls \
	  || exit 1

	for MF in Makefile glib-1.2.8/Makefile ; do
		[ -r $MF.OLD ] || mv $MF $MF.OLD || exit 1
		cat $MF.OLD \
			| sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
			> $MF || exit 1
	done

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_HOST_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	 make DESTDIR=${INSTTEMP} install || exit 1
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
