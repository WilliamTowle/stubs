#!/bin/sh
# 14/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	mv -f Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed 's%DIR.*usr%DIR = ${DESTDIR}/usr%' \
		> Makefile || exit 1

# BUILD...
# ...it's perl. We don't build perl scripts.

#		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_tc_host || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
