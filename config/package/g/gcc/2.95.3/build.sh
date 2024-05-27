#!/bin/sh
# 03/07/2003

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_build()
{
# CONFIGURE...
##	mkdir -p ${SOURCETMP}/gcc-xbuild
##	( cd ${SOURCETMP}/gcc-xbuild && \
#	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH} \
#	 CC=${TARGET_CPU}-uclibc-gcc \
		./configure \
		 --prefix=${INSTTEMP}/usr \
		 --enable-languages=c,c++ \
		 --host=`uname -m`-linux --target=${TARGET_CPU}-linux \
		 --disable-nls --disable-largefile \
			|| exit 1

# BUILD...
	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH} \
	 CC=${TARGET_CPU}-uclibc-gcc \
		make bootstrap || exit 1
	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH} \
	 CC=${TARGET_CPU}-uclibc-gcc \
		make || exit 1

# INSTALL...
		make install || exit 1 \
#	) || exit 1
}

make_tc_host()
{
# CONFIGURE...
		./configure \
		 --prefix=${INSTTEMP}/usr \
		 --enable-languages=c,c++ \
		 --host=`uname -m`-linux --target=`uname -m`-linux \
		 --disable-nls --disable-largefile \
			|| exit 1

# BUILD...
		make bootstrap || exit 1
		make || exit 1

# INSTALL...
		make install || exit 1
}

case "$1" in
distro-cross)
	make_build || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_tc_host || exit 1
	;;
*)
	exit 1
	;;
esac
