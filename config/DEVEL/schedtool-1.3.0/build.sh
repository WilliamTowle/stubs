#!/bin/sh
# 2008-09-21

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed	' /^CC=/ s%g*cc%'${FR_CROSS_CC}'%
			; /^all:/ s/ affinity/ no_affinity/
			; /^install:/ s/ all / /
			; /^MANDIR=/ s%share/%%' \
		> Makefile || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man8 || exit 1
	make DESTPREFIX=${INSTTEMP}/usr install || exit 1
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
