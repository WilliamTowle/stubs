#!/bin/sh
# 2007-12-01

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
	1.6.3)
		if [ ! -r ${FR_LIBCDIR}/lib/libintl.a ] ; then
			echo "$0: CONFIGURE: No 'gettext' built" 1>&2
			exit 1
		fi

		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
			  --disable-nls --disable-largefile \
			  --with-included-regex \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/test -d / s/$(datadir)/$(DESTDIR)$(datadir)/' \
				> ${MF} || exit 1
		done || exit 1
	;;
#	1.7.0)
##		PATH=${UCPATH}/bin:${PATH}
#		  ac_cv_func_regexec=no \
#		  ac_cv_header_regex_h=no \
#		 CC=${FR_CROSS_CC} \
#			./configure --prefix=/usr \
#			  --build=`uname -m` --host=${TARGET_CPU} --target=${TARGET_CPU} \
#			  --disable-nls --disable-largefile \
#			  --with-included-regex \
#			  || exit 1
#	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# BUILD...
	make LDFLAGS='-lintl' || exit 1

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
