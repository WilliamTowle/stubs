#!/bin/sh
# nasm v2.09.10			STUBS (c) and GPLv2 Wm. Towle 1999-2013
# last modified			2013-05-01 (since v0.98.35, 2002-10-21)

#[ "${SYSCONF}" ] && . ${SYSCONF}
#[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ ! -d source ] ; then
		echo "No 'source' - extract failed?"
		exit 1
	else
		cd source || exit 1
	fi

	CC=${FR_HOST_CC} \
		./configure \
			--prefix=${FR_TH_ROOT}/usr \
			--build=${FR_HOST_SYS} --host=${FR_HOST_SYS} \
			--disable-largefile --disable-nls \
			|| exit 1
}

handle_nti()
{
# CONFIGURE...
	# basic NTI/NUI setup
	FR_HOST_CC=/usr/bin/gcc
	FR_HOST_CPU=`uname -m | sed 's/x86_64/i686/'`
	FR_HOST_SYS=${FR_HOST_CPU}-unknown-linux-gnu
	FR_TH_ROOT=${TCTREE}

	do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}


##
##	main program
##

BUILDMODE=$1
[ "$1" ] && shift
case ${BUILDMODE} in
NTI)		## native toolchain install
	handle_nti $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDMODE '${BUILDMODE}'" 1>&2
	exit 1
;;
esac
