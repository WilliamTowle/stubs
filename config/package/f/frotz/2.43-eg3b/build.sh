#!/bin/sh
# 23/12/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

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
