##	stubs-config.sh		STUBS (c)1999-2010 William Towle
##	Last modified		2010-08-18, WmT
##	Purpose			project settings management
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *

STUBSLIB_CFG=config/stubs.cfg
STUBSLIB_CFG_LOADED=n
STUBSLIB_CFG_PREFIX=STUBS
STUBSLIB_PROJCONF=`dirname ${STUBSLIB_CFG}`/project-conf

. ${LIBDIR}/lib-config.sh
lib_init env

stubs_envfile_load()
{
	if [ "${STUBSLIB_CFG_LOADED}" != 'y' ] ; then
		env_envfile_load ${STUBSLIB_CFG} ${STUBSLIB_CFG_PREFIX} && export STUBSLIB_CFG_LOADED=y
	fi
}

stubs_do_show()
{
	stubs_envfile_load
	stubs_configure_projconf
	stubs_configure_buildroot
	stubs_configure_insttemp
	stubs_configure_sourcetree
	stubs_configure_tctree
}

stubs_envfile_save()
{
	echo "Saving..."
	env_envfile_save ${STUBSLIB_CFG} ${STUBSLIB_CFG_PREFIX}
	echo "DONE"
}

stubs_configure_buildroot()
{
	stubs_envfile_load

	if [ "$1" ] ; then
		EXPECTED_PATH=${TOPLEV}/`basename $1`
		env_configure_directory STUBS_BUILDROOT ${EXPECTED_PATH} || echo "WARNING: DIRECTORY ${EXPECTED_PATH} does not exist/is not on expected path"
		stubs_envfile_save
	fi

	echo "STUBS_BUILDROOT: ${STUBS_BUILDROOT:-UNSET}"
}

stubs_configure_insttemp()
{
	stubs_envfile_load

	if [ "$1" ] ; then
		EXPECTED_PATH=${TOPLEV}/`basename $1`
		env_configure_directory STUBS_INSTTEMP ${EXPECTED_PATH} || echo "WARNING: DIRECTORY ${EXPECTED_PATH} does not exist/is not on expected path"
		stubs_envfile_save
	fi

	echo "STUBS_INSTTEMP: ${STUBS_INSTTEMP:-UNSET}"
}

stubs_configure_projconf()
{
	stubs_envfile_load

	if [ "$1" ] ; then
		EXPECTED_PATH=${TOPLEV}/${STUBSLIB_PROJCONF}/`basename $1`
		env_configure_file STUBS_PROJCONF ${EXPECTED_PATH} || echo "WARNING: FILE ${EXPECTED_PATH} does not exist/is not on expected path"
		stubs_envfile_save
	fi

	echo "STUBS_PROJCONF: ${STUBS_PROJCONF:-UNSET}"
}

stubs_configure_sourcetree()
{
	stubs_envfile_load

	if [ "$1" ] ; then
		EXPECTED_PATH=${TOPLEV}/`basename $1`
		env_configure_directory STUBS_SOURCETREE ${EXPECTED_PATH} || echo "WARNING: DIRECTORY ${EXPECTED_PATH} does not exist/is not on expected path"
		stubs_envfile_save
	fi

	echo "STUBS_SOURCETREE: ${STUBS_SOURCETREE:-UNSET}"
}

stubs_configure_tctree()
{
	stubs_envfile_load

	if [ "$1" ] ; then
		EXPECTED_PATH=${TOPLEV}/`basename $1`
		env_configure_directory STUBS_TCTREE ${EXPECTED_PATH} || echo "WARNING: DIRECTORY ${EXPECTED_PATH} does not exist/is not on expected path"
		stubs_envfile_save
	fi

	echo "STUBS_TCTREE: ${STUBS_TCTREE:-UNSET}"
}
