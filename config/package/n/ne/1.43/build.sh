#!/bin/sh -x
# 2008-04-11

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	for MF in `find ./ -name [Mm]akefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/ s%g*cc%'${FR_CROSS_CC}'%' \
			> ${MF} || exit 1
	done

	case ${PKGVER} in
	1.4[12]) ;;
	1.43)
		[ -r src/keys.c.OLD ] || mv src/keys.c src/keys.c.OLD
		cat src/keys.c.OLD \
			| sed '/get_key_code/	s/$/\nint e;/' \
			| sed '/[ 	]const int e/	s/const int //' \
			> src/keys.c || exit 1
	;;
	*)	echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# BUILD...
	( cd src \
		&& make NE_NOWCHAR=1
	) || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	cp src/ne ${INSTTEMP}/usr/local/bin/ || exit 1
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
