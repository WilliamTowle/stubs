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

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

	[ -r lynx.cfg.OLD ] || mv lynx.cfg lynx.cfg.OLD || exit 1
	cat lynx.cfg.OLD \
		| sed '/^#*COLOR:0/	s/[a-z].*/white:black/' \
		| sed '/^#*COLOR:1/	s/[a-z].*/brown:black/' \
		| sed '/^#*COLOR:2/	s/[a-z].*/yellow:blue/' \
		| sed '/^#*COLOR:3/	s/[a-z].*/green:black/' \
		| sed '/^#*COLOR:4/	s/[a-z].*/yellow:black/' \
		| sed '/^#*COLOR:5/	s/[a-z].*/blue:black/' \
		| sed '/^#*COLOR:6/	s/[a-z].*/brightmagenta:black/' \
		| sed '/^#*COLOR:7/	s/[a-z].*/magenta:cyan/' \
		| sed '/^#*COLOR:/	s/^#*//' \
		> lynx.cfg || exit 1

#	for MF in `find ./ -name [Mm]akefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^DEFS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done

# BUILD...
	make CC=${FR_HOST_CC} -C src/chrtrans makeuctb || exit 1
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

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
