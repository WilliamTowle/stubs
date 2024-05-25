##	proj-config.sh	STUBS (c)1999-2010 William Towle
##	Last modified	2010-12-29, WmT
##	Purpose		STUBS project settings management
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *


[ "${HAVE_LIB_PROJECT}" != 'y' ] || return

PROJLIB_CFG_LOADED=n
PROJLIB_PREFIX=PROJECT

. ${LIBDIR}/stubs.sh
. ${LIBDIR}/utils.sh

proj_envfile_load()
{
	stubs_envfile_load
	if [ "${PROJLIB_CFG_LOADED}" != 'y' ] ; then
		if [ -z "${STUBS_PROJCONF}" ] ; then
			echo '$STUBS_PROJCONF needs to be set' 1>&2
			exit 1
		elif [ ! -r ${STUBSLIB_PROJCONF}/${STUBS_PROJCONF} ] ; then
			echo "$0: WARNING: $STUBS_PROJCONF needs to be created" 1>&2
			PROJLIB_CFG_LOADED=y
		else
			env_envfile_load ${STUBSLIB_PROJCONF}/${STUBS_PROJCONF} ${PROJLIB_PREFIX} && PROJLIB_CFG_LOADED=y
		fi
	fi
}

proj_do_show()
{
	proj_envfile_load
	proj_configure_stages
	if env_validate_numeric ${PROJECT_STAGES} ; then
		for STAGENUM in ` utils_seq 1 ${PROJECT_STAGES} ` ; do
			echo "Stage ${STAGENUM}:"
			proj_configure_stagetype ${STAGENUM}
			proj_configure_stageconf ${STAGENUM}
		done
	fi
	proj_configure_target_cpu
}

proj_envfile_save()
{
	echo "Saving..."
	env_envfile_save ${STUBSLIB_PROJCONF}/${STUBS_PROJCONF} ${PROJLIB_PREFIX}
	echo "DONE"
}

proj_configure_stages()
{
	proj_envfile_load

	if [ "$1" ] ; then
		STAGES=$1
		if ! env_validate_numeric ${STAGES} ; then
			echo "proj_configure_stages(): STAGES '${STAGES}' non-numeric" 1>&2
			exit 1
		elif ! env_validate_numeric_limit ${STAGES} 9 ; then
			echo "proj_configure_stages(): STAGES '${STAGES}' too high" 1>&2
			exit 1
		else
			env_configure_value PROJECT_STAGES $1
			proj_envfile_save
		fi
	fi

	echo "PROJECT STAGES: ${PROJECT_STAGES:-UNSET}"
}

proj_configure_stagetype()
{
	proj_envfile_load
	STAGENUM=$1
	STAGETYPE=$2

	if [ -z ${PROJECT_STAGES} ] ; then
		echo "$0: PROJECT_STAGES unset" 1>&2
		exit 1
	elif [ -z "${STAGENUM}" ] ; then
		echo "$0: Need STAGENUM in range 1..${PROJECT_STAGES}" 1>&2
		exit 1
	elif ! env_validate_numeric_limit ${STAGENUM} ${PROJECT_STAGES} ; then
		echo "$0: STAGENUM '${STAGENUM}' not in range 1..${PROJECT_STAGES}" 1>&2
		exit 1
	elif [ "${STAGETYPE}" ] ; then
		if ! env_validate_numeric ${STAGENUM} ; then
			echo "$0: STAGENUM '${STAGENUM}' non-numeric or missing" 1>&2
			exit 1
		else
			env_configure_value PROJECT_STAGE${STAGENUM}_TYPE ${STAGETYPE}
			EXPECTED_PATH=`dirname ${STUBSLIB_CFG}`/${STAGETYPE}-conf
			if [ ! -d ${EXPECTED_PATH} ] ; then
				echo "WARNING: config directory ${EXPECTED_PATH} needs to be created" 1>&2
			fi
			proj_envfile_save
		fi
	fi

	echo "Stage type: "`eval 'echo ${PROJECT_STAGE'${STAGENUM}'_TYPE:-UNSET}'`
}

proj_configure_stageconf()
{
	proj_envfile_load
	STAGENUM=$1
	STAGECONF=$2

	if [ -z ${PROJECT_STAGES} ] ; then
		echo "$0: PROJECT_STAGES unset" 1>&2
		exit 1
	elif ! env_validate_numeric ${STAGENUM} ; then
		echo "$0: STAGENUM '${STAGENUM}' non-numeric or missing" 1>&2
		exit 1
	elif ! env_validate_numeric_limit ${STAGENUM} ${PROJECT_STAGES} ; then
		echo "$0: STAGENUM '${STAGENUM}' not in range 1..${PROJECT_STAGES}" 1>&2
		exit 1
	elif [ "${STAGECONF}" ] ; then
		EXPECTED_PATH=`dirname ${STUBSLIB_CFG}`/`eval 'echo ${PROJECT_STAGE'${STAGENUM}'_TYPE}'`-conf/`basename ${STAGECONF}`
		env_configure_file PROJECT_STAGE${STAGENUM}_CONFIG ${EXPECTED_PATH} || echo "WARNING: FILE ${EXPECTED_PATH} not on expected path"
		proj_envfile_save
	fi

	echo "Stage config: "`eval 'echo ${PROJECT_STAGE'${STAGENUM}'_CONFIG:-UNSET}'`
}

proj_configure_target_cpu()
{
	proj_envfile_load

	if [ "$1" ] ; then
		env_configure_value PROJECT_TARGET_CPU $1
		proj_envfile_save
	fi

	echo "Target CPU:" ${PROJECT_TARGET_CPU:-UNSET}
}

HAVE_LIB_PROJECT=y
