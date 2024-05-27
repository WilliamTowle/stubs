#!/bin/sh
# sys-freedos vUNKNOWN		STUBS (c) and GPLv2 Wm. Towle 1999-2010
# last modified			2010-11-22 (since 2009-01-13)

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
}

handle_nti()
{
# CONFIGURE...
# perl script - no configuration required
#	# basic NTI/NUI setup
#	FR_HOST_CC=/usr/bin/gcc
#	FR_HOST_CPU=`uname -m | sed 's/x86_64/i686/'`
#	FR_HOST_SYS=${FR_HOST_CPU}-unknown-linux-gnu
#	FR_TH_ROOT=${TCTREE}

	do_configure || exit 1

# BUILD...
# perl script - no compilation required
#	make || exit 1

# INSTALL...
	mkdir -p ${TCTREE}/etc/bootsecs || exit 1
	cp -ar bootsecs/* ${TCTREE}/etc/bootsecs/ || exit 1
	mkdir -p ${TCTREE}/usr/bin || exit 1
	sed 's%/bootsecs/%/../../etc/bootsecs/%' sys-freedos.pl > ${TCTREE}/usr/bin/sys-freedos.pl || exit 1
	chmod a+x ${TCTREE}/usr/bin/sys-freedos.pl || exit 1
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
