#!/bin/sh
##	utils.sh	STUBS (c)1999-2010 William Towle
##	Last modified	2010-11-01, WmT
##	Purpose		save state
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *


[ "${HAVE_LIB_UTILS}" != 'y' ] || return

## utils_realpath(): show canonical directory name
## (as per '/usr/bin/realpath')

utils_realpath()
{
	( cd ${1+"$@"} && /bin/pwd )
}


## utils_seq(): emit inclusive range from FRVAL to TOVAL
## (as per '/usr/bin/seq')

utils_seq()
{
	FRVAL=$1
	TOVAL=$2

	while [ ${FRVAL} -le ${TOVAL} ] ; do
		echo ${FRVAL}
		FRVAL=`expr ${FRVAL} + 1`
	done
}

HAVE_LIB_UTILS=y
