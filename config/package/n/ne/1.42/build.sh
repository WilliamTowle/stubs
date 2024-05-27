#!/bin/sh
# 06/12/2005

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
			| sed '/^CC/ s%cc%${CCPREFIX}cc%' \
			| sed '/^CFLAGS/ s%$% '${ADD_INCL_NCURSES}'%' \
			| sed '/^	makeinfo/ s%^%#%' \
			| sed '/^	perl/ s%^%#%' \
			| sed 's/lcurses/lncurses/' \
			> ${MF} || exit 1
	done

	case ${PKGVER} in
	1.35)
		[ -r src/term.c.OLD ] || mv src/term.c src/term.c.OLD \
			|| exit 1
		cat src/term.c.OLD \
			| sed '/\/\//	s%$%*/%' \
			| sed '/\/\//	s%^%/*%' \
			> src/term.c || exit 1
		;;
	1.36|1.39)
		for SF in cm.c ne.h ; do
			[ -r src/${SF}.OLD ] || mv src/${SF} src/${SF}.OLD \
				|| exit 1
			cat src/${SF}.OLD \
				| sed 's%<ncurses/term.h>%<term.h>%' \
				> src/${SF} || exit 1
		done

		[ -r src/term.c.OLD ] || mv src/term.c src/term.c.OLD \
			|| exit 1
		cat src/term.c.OLD \
			| sed '/\/\//	s%$%*/%' \
			| sed '/\/\//	s%^%/*%' \
			| sed 's%<ncurses/term.h>%<term.h>%' \
			> src/term.c || exit 1
		;;
	1.40|1.41|1.42)
		;;
	*)	echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# BUILD...
	# ...no Makefile in SRCXPATH
	( cd src &&
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			OPTS=-ansi NE_NOWCHAR=1
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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
