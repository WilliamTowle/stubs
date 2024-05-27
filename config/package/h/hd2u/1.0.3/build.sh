#!/bin/sh
# 2008-09-11

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/popt.h ] ; then
		echo "$0: Confused -- no popt.h" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	1.0.0)
		# without-included-regex here, as uClibc conflicts
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  ac_cv_func_malloc_0_nonnull=yes \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/-g / /' \
				| sed 's/BUILD_ROOT/DESTDIR/g' \
				> ${MF} || exit 1
		done
	;;
	1.0.2)
		# without-included-regex here, as uClibc conflicts
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  ac_cv_func_malloc_0_nonnull=yes \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/-g / /' \
				| sed 's/BUILD_ROOT/DESTDIR/g' \
				| sed 's/$^/${TARGET}.c/' \
				> ${MF} || exit 1
		done
	;;
	1.0.3)
		# without-included-regex here, as uClibc conflicts
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  ac_cv_func_malloc_0_nonnull=yes \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/-g / /' \
				| sed 's/BUILD_ROOT/DESTDIR/g' \
				| sed 's/$^/${TARGET}.c/' \
				> ${MF} || exit 1
		done
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
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
