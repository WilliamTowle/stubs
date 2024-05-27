#!/bin/sh
# 2008-01-28 (prev 2005-06-20)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PHASE}-${PKGVER} in
	dc-1.9.1)
		 CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
	dc-1.11.[12])
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
#	th)
#	  CC=${FR_HOST_CC} \
#		./configure --prefix=${FR_TH_ROOT}/usr \
#		  --host=`uname -m` --build=`uname -m` \
#		  --disable-largefile --disable-nls \
#		  || exit 1
#
	*)
		echo "$0: Unexpected PKGVER/PHASE ${PKGVER}, ${PHASE}" 1>&2
		exit 1
	;;
	esac

	case ${PHASE}-${FR_TARGET_DEFN} in
	dc*uclibc*|dc*earlgrey*)
		[ -r src/ptimer.c.OLD ] || mv src/ptimer.c src/ptimer.c.OLD
		cat src/ptimer.c.OLD \
			| sed '/^#.*_POSIX_TIMERS/ s% .*% 0 /* force PTIMER_GETTIMEOFDAY for uClibc 0.9.20 */%' \
			> src/ptimer.c || exit 1
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	#PATH=${UCPATH}/bin:${PATH}
		make all || exit 1

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
