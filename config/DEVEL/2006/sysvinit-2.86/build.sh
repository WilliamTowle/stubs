#!/bin/sh
# 05/03/2006

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

#	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
#		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
#		exit 1
#	fi

	case ${PKGVER} in
	2.86)
		find ./ -name "*[Mm]akefile" | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC[ 	]*=/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^	/	s/[(]ROOT[)]/(DESTDIR)/' \
				| sed '/^INSTALL[ 	]*=/	s/-[og] [^ ]*/ /g' \
				> ${MF} || exit 1
		done

		(	echo 'last.o: '`grep '^#include "' src/last.c | sed 's/[^"]*"//' | sed 's/".*//'`
			echo '	${CC} -c ${CFLAGS} last.c'
		) >> src/Makefile
		;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac

	[ -r src/last.c.OLD ] || mv src/last.c src/last.c.OLD || exit 1
	cat src/last.c.OLD \
		| sed 's/origu = u/memcpy('\\'&origu, '\\'&u, sizeof(struct tm));/' \
		> src/last.c || exit 1

# BUILD...
	( cd src || exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1
	) || exit 1

# INSTALL...
	case ${PKGVER} in
	2.86)
		mkdir -p ${INSTTEMP}/bin || exit 1
		mkdir -p ${INSTTEMP}/sbin || exit 1
		mkdir -p ${INSTTEMP}/usr/bin || exit 1
		mkdir -p ${INSTTEMP}/usr/include || exit 1
		mkdir -p ${INSTTEMP}/usr/share/man/man1 || exit 1
		mkdir -p ${INSTTEMP}/usr/share/man/man5 || exit 1
		mkdir -p ${INSTTEMP}/usr/share/man/man8 || exit 1
		mkdir -p ${INSTTEMP}/var/log || exit 1
		( cd src || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
		) || exit 1
		;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac
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
