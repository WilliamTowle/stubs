#!/bin/sh
# 10/12/2005

#TODO: Doesn't need ncurses to build ... but maybe the library does?

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

	if [ -r ${FR_LIBCDIR}/include/dpy.h ] ; then
		if [ ! -r ${FR_LIBCDIR}/lib/libncurses.a ] ; then
			echo "Confused -- no ncurses library" 1>&2
			exit 1
		fi
	else
		echo "$0: Confused -- no dpy.h" 1>&2
		exit 1
	fi

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		( echo 'CC='${FR_CROSS_CC} ; cat ${MF}.OLD ) \
			| sed '/^CFLAGS/ s%-I/usr/local/include% %' \
			| sed '/^CFLAGS/ s%-L/usr/local/lib% %' \
			| sed 's/-ltermcap/-lncurses/' \
			| sed '/^	/ s/libdpy.a/-ldpy/' \
			>> ${MF} || exit 1
	done

# BUILD...
	make clean || exit 1

#		make CCPREFIX=${TARGET_CPU}-uclibc-g hangman || exit 1

		make CCPREFIX=${TARGET_CPU}-uclibc-g lem snake || exit 1

# INSTALL...
#	mkdir -p ${INSTTEMP}/usr/local/games/bin || exit 1
#	cp hangman ${INSTTEMP}/usr/local/games/bin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/local/games/bin || exit 1
	cp lem snake ${INSTTEMP}/usr/local/games/bin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/local/games/doc || exit 1
	cp snake.doc ${INSTTEMP}/usr/local/games/doc/ || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	exit 1
	;;
esac
