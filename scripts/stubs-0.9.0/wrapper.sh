#!/bin/sh
# WmT, 13/04/2004

GENTREE=`pwd`
BUILDSH=${GENTREE}/build.sh
PKGCFG=${GENTREE}/package.cfg

. ${PKGCFG}

if [ -z "$1" ] ; then
	echo "$0: No SYSCONF supplied"
	exit 1
else
	SYSCONF=$1
	shift
fi
if [ -z "$1" ] ; then
	echo "$0: No build.sh args supplied"
	exit 1
fi

if [ ! -d ./source ] ; then
	echo "No ./source - package not extracted?"
	exit 1
fi

[ "${PACKAGE}" ] && INSTTEMP=${GENTREE}/files
if [ -z "${INSTTEMP}" ] ; then
	echo "INSTTEMP unsupplied and not automatically determined" 1>&2
	echo "(ie. no PACKAGE due to PREFIXES)" 1>&2
	exit 1
fi

( cd source && SYSCONF=${SYSCONF} PKGFILE=${PKGCFG} INSTTEMP=${INSTTEMP} ${BUILDSH} $* )
