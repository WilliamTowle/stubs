#!/bin/sh
# sw39tc-init v1.0.0rc1		STUBS (c) and GPLv2 1999-2010
# last modified			2010-12-28

do_configure()
{
## 'package.cfg' gets us PKGNAME, PKGVER, etc.
#	. ./package.cfg || exit 1

	echo -n 'Sanity of BUILDROOT ['${BUILDROOT}']... '
	if [ -z "${BUILDROOT}" ] ; then
		echo ' UNSET - aborting'
		exit 1
	elif [ ! -d ${BUILDROOT} ] ; then
		echo ' missing - aborting'
		exit 1
	else
		echo ' OK'
	fi

	echo -n 'Sanity of SOURCETREE ['${SOURCETREE}']... '
	if [ -z "${SOURCETREE}" ] ; then
		echo ' UNSET - aborting'
		exit 1
	elif [ ! -d ${SOURCETREE} ] ; then
		echo ' missing - aborting'
		exit 1
	else
		echo ' OK'
	fi

	echo -n 'Sanity of TCTREE ['${TCTREE}']... '
	if [ -z "${TCTREE}" ] ; then
		echo ' UNSET - aborting'
		exit 1
	elif [ ! -d ${TCTREE} ] ; then
		echo ' missing - aborting'
		exit 1
	else
		echo ' OK'
	fi

	echo -n 'Sanity of PROJECT_TARGET_CPU ['${PROJECT_TARGET_CPU}']... '
	if [ -z "${TCTREE}" ] ; then
		echo ' UNSET - aborting'
		exit 1
	else
		echo ' OK'
	fi

	export CDPATH=''
	( cd source/toolchain && tar cvf - opt ) | ( cd ${TCTREE} && tar xvf - )
}

handle_nti()
{
# CONFIGURE...
	do_configure || exit 1

# BUILD...

# INSTALL...
	#mkdir -p ${BUILDROOT}/bss
	#mkdir -p ${BUILDROOT}/wmfd
	#mkdir -p ${BUILDROOT}/wmut
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
