##	query-config.sh	STUBS (c)1999-2010 William Towle
##	Last modified	2010-12-29, WmT
##	Purpose		STUBS build-stage configuration management
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *


[ "${HAVE_LIB_STAGE}" != 'y' ] || return

. ${LIBDIR}/project.sh
. ${LIBDIR}/utils.sh

stageconf_emit_all()
{
	proj_envfile_load

	if utils_is_false env_validate_numeric ${PROJECT_STAGES} ; then
		echo '$PROJECT_STAGES needs to be set' 1>&2
		exit  1
	else
		for STAGENUM in ` utils_seq 1 ${PROJECT_STAGES} ` ; do
			stageconf_emit_stage ${STAGENUM} || exit 1
		done
	fi
}

stageconf_emit_stage()
{
	STAGENUM=$1
	proj_envfile_load

	if utils_is_false env_validate_numeric ${PROJECT_STAGES} ; then
		echo '$PROJECT_STAGES needs to be set' 1>&2
		exit  1
	elif utils_is_false env_validate_numeric_limit ${STAGENUM} ${PROJECT_STAGES} ; then
		echo "STAGENUM '${STAGENUM}' not in range 1..${PROJECT_STAGES}" 1>&2
		exit  1
	else
		STAGETYPE=`eval 'echo ${PROJECT_STAGE'${STAGENUM}'_TYPE}'`
		STAGECONF=`eval 'echo ${PROJECT_STAGE'${STAGENUM}'_CONFIG}'`
		CONFIG_FILE=${TOPLEV}/`dirname ${STUBSLIB_CFG}`/${STAGETYPE}-conf/${STAGECONF}

		stageconf_emit_stage_all ${CONFIG_FILE}
	fi
}


#query_buildspec_emit()
#{
#	EMIT=$1
#	while read PKGNAME PKGVER BUILDTYPE ; do
#		#PKGSUBDIR=`echo ${PKGNAME} | cut -c-1 | tr 'A-Z' 'a-z'`
#		PKGSUBDIR=`echo ${PKGNAME} | sed 's/\(.\).*/\1/' | tr 'A-Z' 'a-z'`
#		PKGDIR=${PROJLIB_PKGCONF}/${PKGSUBDIR}/${PKGNAME}/${PKGVER}
#
#		case ${EMIT} in
#		buildspec)
#			echo "${BUILDTYPE} ${PKGDIR}"
#		;;
#		packagedir)
#			echo ${PKGDIR}
#		;;
#		*)
#			echo "query_buildspec_emit(): Unexpected: EMIT=${EMIT}" 1>&2
#			exit 1
#		;;
#		esac
#	done
#}

stageconf_emit_stage_all()
{
	STAGECONF=$1

	if [ -z ${STAGECONF} ] ; then
		echo "stageconf_emit_stage_all(): Expected STAGECONF parameter" 1>&2
		exit 1
	elif [ ! -r ${STAGECONF} ] ; then
		echo "stageconf_emit_stage_all(): STAGECONF ${STAGECONF} not found" 1>&2
		exit 1
	fi

	sed 's/^[ 	]*#.*//' ${STAGECONF} | grep '.'
}

stageconf_query_packages()
{
	if [ -z "$1" ] ; then
		echo "$0: stageconf_query_packages(): Need ARGs (e.g. 'all')" 1>&2
		exit 1
	fi

	case ${1} in
	all)
		stageconf_emit_all
	;;
	*)
		echo "$0: stageconf_query_packages(): Unexpected argument '$1'" 1>&2
		exit 1
	;;
	esac
}

HAVE_LIB_STAGE=y
