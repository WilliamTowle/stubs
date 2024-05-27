#!/bin/sh
# STUBS (c) and GPLv2 Wm.Towle 1999-2014
# Purpose		/etc population for development builds
# Last modified		2014-01-26

handle_cui()
{
# CONFIGURE...

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/etc

	export CDPATH=''
	( cd source/etc && tar cvf - * ) | ( cd ${INSTTEMP}/etc && tar xvf - )

	if [ "${STUBS_PROJCONF}" ] ; then	# exported by build system?
		echo "Projconf ${STUBS_PROJCONF}, built "`date` >${INSTTEMP}/etc/motd
	else
		echo 'System built '`date` >${INSTTEMP}/etc/motd
	fi
}


##
##	main program
##

BUILDMODE=$1
[ "$1" ] && shift
case ${BUILDMODE} in
CUI)		## cross-userland install
	handle_cui $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDMODE '${BUILDMODE}'" 1>&2
	exit 1
;;
esac
