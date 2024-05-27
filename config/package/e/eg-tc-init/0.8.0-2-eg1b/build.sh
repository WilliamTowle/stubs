#!/bin/sh
# 2008-10-03

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_th()
{
# CONFIGURE...
#	# sanitc 27/06/2005+
#	if [ -r ${INSTTEMP}/bin/gcc ] ; then
#		# prebuilt compiler, old layout toolchain
#		FR_TH_PATH=${INSTTEMP}
#		FR_TC_PATH=${INSTTEMP}
#		FR_HOST_CC=${FR_TH_PATH}/bin/gcc
#	else
		# new layout toolchain
		FR_TH_PATH=${INSTTEMP}/host-utils
		FR_TC_PATH=${INSTTEMP}/cross-utils
		FR_HOST_CC=${FR_TH_PATH}/usr/bin/gcc
#	fi

	# Lack of compiler means we're starting completely afresh...
	if [ ! -r ${FR_HOST_CC} ] ; then
		FR_HOST_CC=`which gcc`
		if [ -z "${FR_HOST_CC}" ] ; then
			echo "$0: CONFIGURE: No prebuilt OR native 'gcc'!" 1>&2
			exit 1
		fi
	fi

	if [ ! -d /usr/include/linux ] ; then
		# Assume native and/or prebuilt compiler uses /usr/include
		echo "$0: CONFIGURE: Lacking /usr/include/linux for native builds" 1>&2
		exit 1
	fi

	if [ -z "${TARGET_CPU}" ] ; then
		echo "$0: CONFIGURE: TARGET_CPU unset" 1>&2
		exit 1
	fi

	case _${USER}${UID}_ in
	_root0_|_root_|__) # USER=root and/or UID=0, UID/both unset
		if [ "${UID}0" -eq 0 -o "${USER}" = 'root' ] ; then
			if [ ! -O /dev -o ! -O /dev/null ] ; then
				echo "*** WARNING: Not owner of /dev - correcting ***" 1>&2
				chown -R 0.0 /dev || exit 1
			fi
		fi
	;;
	esac

	if [ -r ${FR_TH_PATH}/bin/grep ] ; then
		TEST=`${FR_TH_PATH}/bin/grep 2>&1 | /bin/grep grep`
		case "${TEST}" in
		*error*)
			echo "$0: CONFIGURE: Bad prebuilt 'grep' - aborting" 1>&2
			exit 1
		;;
		esac
	fi

# BUILD...

# INSTALL...
	# Not all packages do `mkdir -p` (eg. via 'install-sh'). Make dirs:
	mkdir -p ${FR_TH_PATH} || exit 1
	mkdir -p ${FR_TC_PATH} || exit 1

	# ...and add some directories/utilities of our own:
	mkdir -p ${TCTREE}/etc/${USE_DISTRO} || exit 1
	tar cvf - opt | ( cd ${TCTREE} && tar xvf - )
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
#native-build)
#	INSTTEMP=/ make_th || exit 1
#;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Bad COMMAND $1" 1>&2
	exit 1
;;
esac
