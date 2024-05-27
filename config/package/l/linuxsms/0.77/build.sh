#!/bin/sh
# 14/07/2003

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_build()
{
# CONFIGURE...
	mv -f Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed 's%DIR.*usr%DIR = ${DESTDIR}/usr%' \
		> Makefile || exit 1

# BUILD...
# ...it's perl. We don't build perl scripts.
#	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH} \
#		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

#make_tc_host()
#{
#	./configure --prefix=${INSTTEMP}/usr || exit 1
#	make || exit 1
#	make prefix=${INSTTEMP}/usr install || exit 1
#}

case "$1" in
distro-cross)
	make_build || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_tc_host || exit 1
#	;;
*)
	exit 1
	;;
esac
