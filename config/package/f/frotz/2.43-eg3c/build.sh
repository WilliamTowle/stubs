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

	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
# | sed '/^FLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${FR_LIBCDIR}'/include/ncurses -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	cat Makefile.OLD \
		| sed '/^CC =/ s/gcc/${CCPREFIX}cc/' \
		| sed '/= \/usr\/local/ s%= /usr%= ${DESTDIR}/usr%' \
		| sed '/install:/ s/:.*/:/' \
		| sed '/^FLAGS/ s%$% '${ADD_INCL_NCURSES}'%' \
		> Makefile || exit 1

	[ -r src/misc/findsound.sh.OLD ] \
		|| mv src/misc/findsound.sh src/misc/findsound.sh.OLD \
		|| exit 1
	cat src/misc/findsound.sh.OLD \
		| sed '/^INCLUDE[123]=/ s%/usr%'${TCTREE}'/usr%' \
		> src/misc/findsound.sh

# BUILD...
	make clean || exit 1

	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  CURSES=-lncurses \
		  || exit 1

# INSTALL...
	# tries to recompile. Force continue after fail with '-k'
	make DESTDIR=${INSTTEMP} -k install || exit 1
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
