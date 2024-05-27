#!/bin/sh
# 2008-09-21

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	1.6.[34])
		if [ ! -r ${FR_LIBCDIR}/lib/libasprintf.a ] ; then
			echo "$0: CONFIGURE: No 'gettext' built" 1>&2
			exit 1
		fi

		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=${FR_HOST_DEFN} --build=${FR_TARGET_DEFN} \
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
	1.7.0)
##		PATH=${UCPATH}/bin:${PATH}
#		  ac_cv_func_regexec=no \
#		  ac_cv_header_regex_h=no \
		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --build=`uname -m` --host=${TARGET_CPU} --target=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# BUILD...
	case ${PKGVER} in
	1.6.[34])
		make LDFLAGS='-lintl' || exit 1
	;;
	1.7.0)
		make LDFLAGS='-lintl' || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

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
