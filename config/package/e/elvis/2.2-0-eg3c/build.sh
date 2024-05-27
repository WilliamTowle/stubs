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
		./configure \
		 --prefix=/usr/local \
		 --with-x=no --libs="" \
		 `uname -s | tr 'A-Z' 'a-z'` \
		 || exit 1

# ...regenerate Makefile
	mv Makefile Makefile.OLD || exit 1
# | sed '/^CFLAGS=/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${FR_LIBCDIR}'/include/ncurses -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	cat Makefile.OLD \
		| sed '/^CFLAGS=/ s%$% '${ADD_INCL_NCURSES}'%' \
		| sed '/^PREFIX=/ s%/%${DESTDIR}/%' \
		| sed 's%/etc/elvis%${DESTDIR}/etc/elvis%'g \
		> Makefile || exit 1

	[ -r instman.sh.OLD ] || mv instman.sh instman.sh.OLD || exit 1
	cat instman.sh.OLD \
		| sed "s%/usr/man%${INSTTEMP}/usr/man%g" \
		> instman.sh || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/local/share/elvis/doc || exit 1
	mkdir -p ${INSTTEMP}/etc/elvis || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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
