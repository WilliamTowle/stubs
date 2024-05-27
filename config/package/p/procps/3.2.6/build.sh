#!/bin/sh
# 27/01/2005

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

#	case ${USE_DISTRO} in
#	*-0.7*)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed 's%$(CC)%'${FR_CROSS_CC}'%' \
			| sed '/^ALL_CPPFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include '${ADD_INCL_NCURSES}' -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
			| sed '/^CPPFLAGS/ s%=.*%%' \
			| sed 's%= ldconfig%= %' \
			| sed 's/--owner 0//' \
			| sed 's/--group 0//' \
			> Makefile || exit 1
#		;;
#	*)
#		echo "$0: Unexpected DISTRO ${USE_DISTRO}" 1>&2
#		exit 1
##	if [ ! -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
##		echo "$0: Confused -- no ncurses.h" 1>&2
##		exit 1
##	fi || exit 1
##
##	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
##	cat Makefile.OLD \
##		| sed 's%$(CC)%'${FR_CROSS_CC}'%' \
##		| sed '/^ALL_CPPFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
##		| sed '/^CPPFLAGS/ s%=.*%%' \
##		| sed 's%= ldconfig%= %' \
##		| sed 's/--owner 0//' \
##		| sed 's/--group 0//' \
##		> Makefile || exit 1
#		;;
#	esac \
#		|| exit 1

	[ -r proc/escape.c.OLD ] || mv proc/escape.c proc/escape.c.OLD || exit 1
	cat proc/escape.c.OLD \
		| sed '/#if.*__GNU_LIBRARY__/ s%^%#if 0 /* %' \
		| sed '/#if.*__GNU_LIBRARY__/ s%$% */%' \
		> proc/escape.c || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CC=${FR_CROSS_CC} \
		  || exit 1

# INSTALL...
	# v3.2.4 still wants to build stuff...
	make DESTDIR=${INSTTEMP} \
		CC=${FR_CROSS_CC} \
		  install || exit 1
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
