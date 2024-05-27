#!/bin/sh

if [ -z "$1" ] ; then
	echo "$0: Expected INSTTEMP" 1>&2
	exit 1
fi

find ${1+"$@"} -type f | while read F ; do basename $F ; done | sort
