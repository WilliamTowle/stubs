#!/bin/sh
##	build		STUBS (c) and GPLv2 Wm. Towle 1999-2010
##	Last modified	2010-12-29
##	Purpose		quick build
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *

do_build()
{
	if [ -z "$1" ] ; then
		echo "$0: No BUILDTYPE" 1>&2
		exit 1
	elif [ -z "$2" ] ; then
		echo "$0: No BUILDTEMP" 1>&2
		exit 1
	elif [ ! -d "$2" ] ; then
		echo "$0: BUILDTEMP $2 not directory" 1>&2
		exit 1
	fi

	BUILDTYPE=$1
	BUILDTEMP=$2

#	BUILDROOT=${STUBS_BUILDROOT+${TOPLEV}/${STUBS_BUILDROOT}} \
#	BUILDTEMP=${BUILDTEMP} \
#	INSTTEMP=${STUBS_INSTTEMP+${TOPLEV}/${STUBS_INSTTEMP}} \
#	  SOURCETREE=${STUBS_SOURCETREE+${TOPLEV}/${STUBS_SOURCETREE}} \
#	  TCTREE=${STUBS_TCTREE+${TOPLEV}/${STUBS_TCTREE}} \
#		./build.sh ${BUILDMODE}

	. config/stubs.cfg

	( cd ${BUILDTEMP} || exit 1
		BUILDROOT=${OLDPWD}/${STUBS_BUILDROOT} \
		  BUILDTEMP=${BUILDTEMP} \
		  INSTTEMP=${OLDPWD}/${STUBS_INSTTEMP} \
		  SOURCETREE=${OLDPWD}/${STUBS_SOURCETREE} \
		  TCTREE=${OLDPWD}/${STUBS_TCTREE} \
			./build.sh ${BUILDTYPE}
	) || exit 1
}

do_build ${1+"$@"}
