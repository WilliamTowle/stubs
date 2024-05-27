#!/bin/sh
# 01/01/2005

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

	case ${PKGVER} in
	0.9.7*)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		 slrn_cv_va_copy=no \
		 slrn_cv___va_copy=no \
		 slrn_cv_va_val_copy=no \
		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr || exit 1
		;;
	0.9.8*)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		 slrn_cv_va_copy=no \
		 slrn_cv___va_copy=no \
		 slrn_cv_va_val_copy=no \
		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
		;;
	*)	echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac \
		|| exit 1
echo "FIX GCCINCDIR"
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's% -I. % -I${INCLROOT}/usr/include -I. %' \
			| sed 's%-L/usr/lib -lslang%-L${INCLROOT}/usr/lib -lslang -ldl%' \
			| sed '/^INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
			> ${MF} || exit 1
	done || exit 1

# BUILD...
	case ${PKGVER} in
	0.9.7*)
# ...start with a native chkslang:
		make -C intl CC=${FR_HOST_CC} libintl.a || exit 1
		make -C src INCLROOT=${TCTREE} CC=${FR_HOST_CC} chkslang || exit 1
		cp src/chkslang ./ || exit 1

# ...now rebuild everything (but targetted sanely) up to the same point
		rm -rf `find ./ -name "*.[oa]"` || exit 1
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make -C intl libintl.a || exit 1
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make -C src INCLROOT=${TCTREE} chkslang || exit 1
# ...and replace the native chkslang.
		touch chkslang || exit 1
		mv chkslang src/ || exit 1

# ...continue cross-build:
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make INCLROOT=${TCTREE} all || exit 1
		;;
	0.9.8*)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make all || exit 1
		;;
	*)	echo "$0: Unpexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac \
		|| exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_tc_host || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
