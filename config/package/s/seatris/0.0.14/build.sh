#!/bin/sh
# 16/05/2005

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

	PATH=${TCTREE}/bin:${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  CFLAGS=${ADD_INCL_NCURSES} \
	  LDFLAGS="-L${FR_LIBCDIR}/lib -lncurses" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

	find ./ -name Makefile | while read MF ; do
		[ -r ${MF}.OLD } || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	.*LIBS/	s%$% -L'${FR_LIBCDIR}'/lib -lncurses %' \
			| sed 's%\$(PREFIX)%$(INSTTEMP)$(PREFIX)%' \
			| sed 's% /var% $(INSTTEMP)/var%' \
			| sed 's/-o root//' \
			| sed 's/-g games//' \
			| sed 's/-g root//' \
			| sed '/^	chown/	s/^/#/' \
			> ${MF} || exit 1
	done
# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/games || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man6 || exit 1
	mkdir -p ${INSTTEMP}/var/lib/games || exit 1
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
