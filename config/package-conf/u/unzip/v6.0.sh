#!/bin/sh
# unzip v6.0			STUBS (c) and GPLv2 Wm. Towle 1999-2010
# last modified			2010-11-22 (since v5.50, c.2003-01-09)

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

	[ -r unix/Makefile.OLD ] || mv unix/Makefile unix/Makefile.OLD || exit 1
	cat unix/Makefile.OLD \
		| sed '/^CC[ 	]/	s%cc#.*%'${FR_HOST_CC}'%' \
		> unix/Makefile || exit 1
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
	make -f unix/Makefile generic || exit 1

# INSTALL...
	mkdir -p ${TCTREE}/usr/bin || exit 1
	mkdir -p ${TCTREE}/usr/man/man1 || exit 1

	for FILE in unzip funzip unzipsfx ; do \
		cp ${FILE} ${TCTREE}/usr/bin/ || exit 1 ;\
	done
	cp man/*.1 ${TCTREE}/usr/man/man1/ || exit 1
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
