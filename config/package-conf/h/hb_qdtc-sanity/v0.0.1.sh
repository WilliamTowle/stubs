#!/bin/sh
# STUBS (c) and GPLv2 Wm.Towle 1999-2012
# Purpose		toolchain sanity check
# Last modified		2012-06-13 (since 2012-06-13)

do_configure()
{
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

	echo -n 'Sanity of INSTTEMP ['${INSTTEMP}']... '
	if [ -z "${INSTTEMP}" ] ; then
		echo ' UNSET - aborting'
		exit 1
	elif [ ! -d ${INSTTEMP} ] ; then
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

	export CDPATH=''
	( cd source/toolchain && tar cvf - etc ) | ( cd ${TCTREE} && tar xvf - )
}

handle_cti()
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
CTI)		## cross-toolchain install
	handle_cti $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDMODE '${BUILDMODE}'" 1>&2
	exit 1
;;
esac
