#!/bin/sh
# wget v1.5.3			STUBS (c) and GPLv2 Wm. Towle 1999-2011
# last modified			2011-04-11 (since v1.5.3, c.2003-06-07)

#[ "${SYSCONF}" ] && . ${SYSCONF}
#[ "${PKGFILE}" ] && . ${PKGFILE}

. package.cfg

do_configure()
{
	if [ ! -d source ] ; then
		echo "No 'source' - extract failed?"
		exit 1
	else
		cd source/wget-${PKGVER} || exit 1
	fi

	CC=${FR_HOST_CC} \
		./configure --prefix=${FR_TH_ROOT}/usr \
		  --host=${FR_HOST_SYS} --build=${FR_HOST_SYS} \
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

	# classic PHASE=tc configuration
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
