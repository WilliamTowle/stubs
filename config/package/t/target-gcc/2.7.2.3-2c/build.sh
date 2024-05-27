#!/bin/sh
# 21/05/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_th()
{
# CONFIGURE...
	HOST_CPU=`uname -m`
	HOST_SYS=`uname -s | tr A-Z a-z`

	mkdir -p ../gcc-build || exit 1
	( cd ../gcc-build || exit 1
	[ -r Makefile ] && rm -rf ./*

	../source/configure \
	  	--prefix=${TCTREE}/usr/kgcc-${PKGVER} \
		--local-prefix=${TCTREE}/usr/kgcc-${PKGVER} \
	  	--build=${TARGET_CPU}-linux \
	  	--target=${TARGET_CPU}-linux \
		--enable-languages=c \
		--disable-shared \
		--disable-__cxa_atexit \
	  	|| exit 1

# BUILD...
	# added 'OLDCC=' to keep willow happy (has no 'cc')
	make CC=gcc OLDCC=gcc || exit 1

# INSTALL...
	make install || exit 1
	) || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	exit 1
	;;
esac
