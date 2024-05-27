#!/bin/sh
# 20/05/2007 (since 27/06/2005?)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_th()
{
# CONFIGURE...
	# sanitc 27/06/2005+
	if [ -d ${INSTTEMP}/host-utils ] ; then
		FR_TH_PATH=${INSTTEMP}/host-utils
	else
		FR_TH_PATH=${INSTTEMP}
	fi
	if [ -r ${FR_TH_PATH}/usr/bin/gcc ] ; then
		FR_HOST_CC=${FR_TH_PATH}/usr/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	#FR_OLDGCC_TARGET=`uname -m`-`uname -s | tr A-Z a-z`
	FR_OLDGCC_TARGET=${TARGET_CPU}-`uname -s | tr A-Z a-z`

	mkdir -p ../gcc-build || exit 1
	( cd ../gcc-build || exit 1
	[ -r Makefile ] && rm -rf ./*

	../source/configure \
	  	--prefix=${TCTREE}/cross-utils/usr \
		--local-prefix=${TCTREE}/cross-utils/usr \
		--program-prefix=${TARGET_CPU}-linux-${PKGVER}-gnu-k \
	  	--build=${FR_OLDGCC_TARGET} \
	  	--target=${FR_OLDGCC_TARGET} \
		--enable-languages=c \
		--disable-shared \
		--disable-__cxa_atexit \
	  	|| exit 1

# BUILD...
	# added 'OLDCC=' to keep willow happy (no pathed 'cc')
	make CC=${FR_HOST_CC} OLDCC=${FR_HOST_CC} || exit 1

# INSTALL...
	# CDPATH makes 'cd' verbose (...and tar copy fails)
	CDPATH='' make install || exit 1
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
