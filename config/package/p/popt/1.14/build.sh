#!/bin/sh
# 19/12/2005

# TODO: "libtool: install: warning: remember to run 'libtool --finish /usr/lib'"

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	1.7)
		# PATH to [x]gettext
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=${FR_HOST_DEFN} --build=${TARGET_CPU} \
			  --disable-largefile \
			  || exit 1
	;;
	1.14)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  ac_cv_va_copy=no \
			./configure --prefix=/usr \
			  --host=${FR_HOST_DEFN} --build=${FR_TARGET_DEFN} \
			  --disable-largefile \
			  || exit 1

		[ -r popthelp.c.OLD ] || mv popthelp.c popthelp.c.OLD || exit 1
		cat popthelp.c.OLD \
			| sed '/define[ 	]POPT_WCHAR_HACK/ s/define/undef/' \
			> popthelp.c || exit 1
	;;
	*)	echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	make CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=tc do_configure || exit 1

# BUILD...
	make CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	make prefix=${FR_LIBCDIR} install || exit 1
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
