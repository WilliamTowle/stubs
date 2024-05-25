#!/bin/sh
##	build		STUBS (c) and GPLv2 Wm. Towle 1999-2010
##	Last modified	2010-12-29
##	Purpose		build control
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *

[ "${LIB_ENVFILE_INIT}" ]	|| LIB_ENVFILE_INIT=n
[ "${LIB_PACKAGE_INIT}" ]	|| LIB_PACKAGE_INIT=n
[ "${LIB_PROJECT_INIT}" ]	|| LIB_PROJECT_INIT=n
[ "${LIB_STAGE_INIT}" ]		|| LIB_STAGE_INIT=n
[ "${LIB_STUBS_INIT}" ]		|| LIB_STUBS_INIT=n
[ "${LIB_UTILS_INIT}" ]		|| LIB_UTILS_INIT=n

lib_init()
{
	while [ "$1" ] ; do
		LIBSPEC=$1
		shift

		case ${LIBSPEC} in
		env)
			if [ "${LIB_ENVFILE_INIT}" = 'n' ] ; then
				. ${LIBDIR}/envfile.sh && LIB_ENVFILE_INIT=y
			fi
		;;
		package)
			if [ "${LIB_PACKAGE_INIT}" = 'n' ] ; then
				. ${LIBDIR}/package.sh && LIB_PACKAGE_INIT=y
			fi
		;;
		project)
			if [ "${LIB_PROJECT_INIT}" = 'n' ] ; then
				. ${LIBDIR}/project.sh && LIB_PROJECT_INIT=y
			fi
		;;
		stage)
			if [ "${LIB_STAGE_INIT}" = 'n' ] ; then
				. ${LIBDIR}/stage.sh && LIB_STAGE_INIT=y
			fi
		;;
		stubs)
			if [ "${LIB_STUBS_INIT}" = 'n' ] ; then
				. ${LIBDIR}/stubs.sh && LIB_STUBS_INIT=y
			fi
		;;
		utils)
			if [ "${LIB_UTILS_INIT}" = 'n' ] ; then
				. ${LIBDIR}/utils.sh && LIB_UTILS_INIT=y
			fi
		;;
		*)	echo "$0: lib_init(): Unexpected LIBSPEC '${LIBSPEC}'" 1>&2
			exit 1
		;;
		esac
	done
}
