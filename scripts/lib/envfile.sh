#!/bin/sh
##	env-config.sh	STUBS (c)1999-2010 William Towle
##	Last modified	2008-02-25, WmT
##	Purpose		save state
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *

env_envfile_load()
{
	FILEPATH=$1
	PREFIX=$2

	case ${FILEPATH} in
	/*)	;;	## absolute path
	*)		## relative path - prepend TOPLEV
		if [ -z "${BINDIR}" ] ; then
			echo "Library error - calling script has not set BINDIR" 1>&2
			exit 1
		fi

		## acquire TOPLEV
		case ${BINDIR} in
		/*)	TOPLEV=`dirname ${BINDIR}`	;;
		*)	TOPLEV=`dirname ${PWD}/${BINDIR}` ;;
		esac

		FILEPATH=${TOPLEV}/${FILEPATH}
	;;
	esac

	LOAD_OK=y
	# don't fall over if there isn't a file yet:
	grep '^'${PREFIX}'_' ${FILEPATH} >tmp.$$ 2>/dev/null
	# ...but if we can't write a tempfile, that's bad:
	. ./tmp.$$ || LOAD_OK=n

	rm tmp.$$ 2>/dev/null
	[ ${LOAD_OK} = 'y' ]
}

env_envfile_save()
{
	FILEPATH=$1
	PREFIX=$2

	case ${FILEPATH} in
	/*)	;;
	*)	FILEPATH=${TOPLEV}/${FILEPATH} ;;
	esac

	set | grep '^'${PREFIX}'_' > ${FILEPATH}
}

env_validate_numeric()
{
	NUM=$1

	[ "${NUM}" -gt 0 ] 2>/dev/null
}

env_validate_numeric_limit()
{
	NUM=$1
	LIMIT=$2

	[ "${NUM}" -le "${LIMIT}" ] 2>/dev/null
}

env_configure_directory()
{
	VARNAME=$1
	FILENAME=$2

	eval "${VARNAME}="`basename ${FILENAME}`
	[ -d ${FILENAME} ]
}

env_configure_file()
{
	VARNAME=$1
	FILENAME=$2

	eval "${VARNAME}="`basename ${FILENAME}`
	[ -r ${FILENAME} ]
}

env_configure_value()
{
	VARNAME=$1
	VAL=$2

	eval "${VARNAME}=${VAL}"
}
