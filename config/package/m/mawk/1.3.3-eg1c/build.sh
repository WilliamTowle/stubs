#!/bin/sh
# 2008-10-16

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	# NB. can't always run the tests; failure seems to happen due to
	# 'trap' support in the shell (bash >= 3.0.x). To fix: use
	# SHELL=`which ash` to build with 'mawk_and_test'

	case ${PHASE} in
	dc)
		# assumes FR_CROSS_CC is gcc v2.x
		CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
		  MATHLIB=-lm \
			./configure \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^BINDIR/ s%/usr.*bin%${DESTDIR}/usr/bin%' \
				| sed '/^MANDIR/ s%/usr.*man1%${DESTDIR}/usr/man/man1%' \
				> ${MF} || exit 1
		done
#		| sed '/^	/ s%./mawktest%${SHELL} ./mawktest%' \
#		| sed '/^	/ s%./fpe_test%${SHELL} ./fpe_test%' \
	;;
	th)
		CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
		  MATHLIB=-lm \
			./configure --prefix=${FR_TH_ROOT}/usr --exec-prefix=${FR_TH_ROOT}/usr \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^BINDIR/ s%/usr.*bin%${DESTDIR}/usr/bin%' \
				| sed '/^MANDIR/ s%/usr.*man1%${DESTDIR}/usr/man/man1%' \
				> ${MF} || exit 1
		done
	;;
	*)	echo "$0: do_configure(): Unexpected PHASE ${PHASE}" 1>&2
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
	make mawk \
	  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=th do_configure || exit 1

# BUILD...
	if [ -r ${FR_TC_ROOT}/bin/sh ] ; then
		make SH=${FR_TC_ROOT}/bin/sh mawk_and_test || exit 1
	else
		make mawk || exit 1
	fi

# INSTALL...
	mkdir -p ${FR_TH_ROOT}/usr/bin || exit 1
	mkdir -p ${FR_TH_ROOT}/usr/man/man1 || exit 1
	make DESTDIR=${FR_TH_ROOT} install || exit 1

	( cd ${FR_TH_ROOT}/usr/bin && ( \
		ln -sf mawk awk \
	) || exit 1 ) || exit 1
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
