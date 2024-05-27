##	STUBS (c) and GPLv2 1999-2017 Wm. Towle
##	Purpose			STUBS package configuration management
##	Last modified		WmT, 2017-03-04
#
#*   Open Source software - copyright and GPLv2 apply. Briefly:       *
#*    - No warranty/guarantee of fitness, use is at own risk          *
#*    - No restrictions on strictly-private use/copying/modification  *
#*    - No re-licensing this work under more restrictive terms        *
#*    - Redistributing? Include/offer to deliver original source      *
#*   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html  *

PROJLIB_PKGCONF=`dirname ${STUBSLIB_CFG}`/package-conf

pkgconf_emit_details()
{
	stubs_envfile_load

	EMIT=$1
	shift

	if [ -z "$1" ] ; then
		echo "*** $0: pkgconf_emit_details(): No PKGCONF[s] ***" 1>&2
		exit 1
	fi

	PKGDIR=`dirname $1`
	PKGCONF=`basename $1`
	shift

	if [ ! -d ${PKGDIR} ] ; then
		echo "*** $0: pkgconf_emit_details(): PKGDIR ${PKGDIR} does not exist ***" 1>&2
		exit 1
	elif [ ! -r ${PKGDIR}/${PKGCONF} ] ; then
		echo "*** $0: pkgconf_emit_details(): No configuration for package in PKGDIR ${PKGDIR} ***" 1>&2
		exit 1
	fi

	. ${PKGDIR}/${PKGCONF} || exit 1
	grep '^SRC[0-9]*=' ${PKGDIR}/${PKGCONF} | while read SRCSPEC ; do
		eval `echo ${SRCSPEC} | sed 's/^SRC[^=]*/SRC/'`
		case ${EMIT} in
		checkdirs)
			echo "${PKGNAME} ver ${PKGVER}${PKGREV}: OK"
		;;
		tarballs)
			SRC_BASENAME=`basename ${SRC}`
			#SRC_SUBDIR=`echo ${SRC_BASENAME} | cut '-c-1' | tr 'A-Z' 'a-z'`
			SRC_SUBDIR=`echo ${SRC_BASENAME} | sed 's/\(.\).*/\1/' | tr 'A-Z' 'a-z'`
			echo ${TOPLEV}/${STUBS_SOURCETREE}/${SRC_SUBDIR}/${SRC_BASENAME}
		;;
		urls)
			echo ${SRC}
		;;
		*)
			echo "*** pkgconf_emit_details(): Unexpected EMIT=${EMIT} ***" 1>&2
			exit 1
		;;
		esac
	done
}

pkgconf_transform_stageconf()
{
	EMIT=$1
	PKGNAME=$2
	PKGVER=$3
	BUILDMODE=$4

	#PKGSUBDIR=`echo ${PKGNAME} | cut -c-1 | tr 'A-Z' 'a-z'`
	PKGSUBDIR=`echo ${PKGNAME} | sed 's/\(.\).*/\1/' | tr 'A-Z' 'a-z'`

	PKGDIR=${PROJLIB_PKGCONF}/${PKGSUBDIR}/${PKGNAME}
	if [ -r ${PKGDIR}/v${PKGVER}${PKGREV}.cfg ] ; then
	    # prefer version-specific name if it exists...
	    PKGCONF=v${PKGVER}${PKGREV}.cfg
	else
	    # ...but default to 'package.cfg'
	    # bail elsewhere [later in pipeline] if missing
	    PKGCONF=package.cfg
	fi

	case ${EMIT} in
	buildspec)
		# TODO: fixed filenames here is a hack!
		echo "${PKGDIR} ${BUILDMODE} ${PKGCONF}"
	;;
#	packagedir)
#		echo ${PKGDIR}
#	;;
	*)
		echo "*** $0: pkgconf_emit_buildspec(): Unexpected: EMIT=${EMIT} ***" 1>&2
		exit 1
	;;
	esac
}

do_pkgconf_build_init()
{
	if [ -d ${BUILDTEMP}/source ] ; then
		rm -rf ${BUILDTEMP}/source
	fi
	mkdir -p ${BUILDTEMP}/source

	pkgconf_emit_details urls ${PKGDIR}/${PKGCONF} | while read SRCURL ; do
		case `echo ${SRCURL} | tr 'A-Z' 'a-z'` in
		file://*)
			SRCDIR=`dirname ${SRCURL} | sed 's%file://%%'`
			SRCFILE=`basename ${SRCURL}`
		;;
		*.gz|*.tgz|*.bz2|*.xz|*.zip|*.com|*.exe|*.exe.gz|*.sys|*.patch*)
			## SCHEME://SERVER/PATH/FILE -- dirname/basename OK
			#SRCDIR=${TOPLEV}/${STUBS_SOURCETREE}/`basename ${SRCURL} | cut -c-1 | tr 'A-Z' 'a-z'`
			SRCDIR=${TOPLEV}/${STUBS_SOURCETREE}/`basename ${SRCURL} | sed 's/\(.\).*/\1/' | tr 'A-Z' 'a-z'`
			SRCFILE=`basename ${SRCURL}`
		;;
		*?use_mirror=*)
			## SourceForge hosted
			SRCFILE=`basename ${SRCURL} | sed 's/?.*//'`
			#SRCDIR=${TOPLEV}/${STUBS_SOURCETREE}/`echo ${SRCFILE} | cut -c-1 | tr 'A-Z' 'a-z'`
			SRCDIR=${TOPLEV}/${STUBS_SOURCETREE}/`echo ${SRCFILE} | sed 's/\(.\).*/\1/' | tr 'A-Z' 'a-z'`
		;;
		*.tar.bz2/download|*.tar.gz/download|*.zip/download)
			## SourceForge 2012
			SRCFILE=`echo ${SRCURL} | sed 's%/download$%% ; s%.*/%%'`
			#SRCDIR=${TOPLEV}/${STUBS_SOURCETREE}/`echo ${SRCFILE} | cut -c-1 | tr 'A-Z' 'a-z'`
			SRCDIR=${TOPLEV}/${STUBS_SOURCETREE}/`echo ${SRCFILE} | sed 's/\(.\).*/\1/' | tr 'A-Z' 'a-z'`
		;;
		*)
			## FUTURE: cases 'basename' fails
			## e.g. SCHEME://SERVER/PATH/SCRIPT?FILE
			echo "*** $0: do_pkgconf_build_init(): Unhandled URL pattern ${SRCURL} ***" 1>&2
			exit 1
		;;
		esac

		if [ ! -r ${SRCDIR}/${SRCFILE} ] ; then
			echo "*** $0: do_pkgconf_build_init(): Not downloaded: ${SRCURL} ***" 1>&2
			exit 1
		fi

		# maybe we need better/missing (un)archivers PATHed?
		[ -d ${TCTREE}/bin ] && PATHPFX=${TCTREE}/bin:
		[ -d ${TCTREE}/usr/bin ] && PATHPFX=${PATHPFX}${TCTREE}/usr/bin:
		[ -d ${TCTREE}/sbin ] && PATHPFX=${PATHPFX}${TCTREE}/sbin:
		[ -d ${TCTREE}/usr/sbin ] && PATHPFX=${PATHPFX}${TCTREE}/usr/sbin:

		case `echo ${SRCFILE} | tr 'A-Z' 'a-z'` in
		*.com|*.exe|*.exe.gz|*.sys|*.patch*)
			cp ${SRCDIR}/${SRCFILE} ${BUILDTEMP}/source || exit 1
		;;
		*.bz2)
			PATH=${PATHPFX}${PATH} bzip2 -dc ${SRCDIR}/${SRCFILE} | tar xvf - -C ${BUILDTEMP}/source || exit 1
		;;
		*.gz|*.tgz)
			PATH=${PATHPFX}${PATH} gzip -dc ${SRCDIR}/${SRCFILE} | tar xvf - -C ${BUILDTEMP}/source || exit 1
		;;
		*.xz)
			PATH=${PATHPFX}${PATH} xz -dc ${SRCDIR}/${SRCFILE} | tar xvf - -C ${BUILDTEMP}/source || exit 1
		;;
		*.zip)
			PATH=${PATHPFX}${PATH} unzip -o ${SRCDIR}/${SRCFILE} -d ${BUILDTEMP}/source || exit 1
		;;
		*)
			echo "*** $0: Unhandled extract filetype for ${SRCFILE} ***" 1>&2
			exit 1
		esac
	done

	if [ "${SRCXPATH}" ] ; then
		( cd ${BUILDTEMP}/source || exit 1
			mv ${SRCXPATH}/* ${SRCXPATH}/.[a-zA-Z0-9]* ./ 2>/dev/null
			rmdir ${SRCXPATH}
		)
	fi
}

do_pkgconf_build_make()
{
	# import variables for TARGET_CPU, etc
	proj_envfile_load

	case ${BUILD_METHOD} in
	SCRIPT)
		export BUILDROOT=${STUBS_BUILDROOT+${TOPLEV}/${STUBS_BUILDROOT}}
		export BUILDTEMP=${BUILDTEMP}
		export BUILDMODE=${BUILDMODE}
		export INSTTEMP=${STUBS_INSTTEMP+${TOPLEV}/${STUBS_INSTTEMP}}
		export SOURCETREE=${STUBS_SOURCETREE+${TOPLEV}/${STUBS_SOURCETREE}}
		export TCTREE=${STUBS_TCTREE+${TOPLEV}/${STUBS_TCTREE}}
		export TARGET_CPU=${PROJECT_TARGET_CPU}

		( cd ${BUILDTEMP} || exit 1
			[ -d ${TCTREE}/bin ] && PATHPFX=${TCTREE}/bin:
			[ -d ${TCTREE}/usr/bin ] && PATHPFX=${PATHPFX}${TCTREE}/usr/bin:
			[ -d ${TCTREE}/sbin ] && PATHPFX=${PATHPFX}${TCTREE}/sbin:
			[ -d ${TCTREE}/usr/sbin ] && PATHPFX=${PATHPFX}${TCTREE}/usr/sbin:
			PATH=${PATHPFX}${PATH} ./build.sh ${BUILDMODE}
		) || exit 1
	;;
	MAKEFILE)
		export BUILDROOT=${STUBS_BUILDROOT+${TOPLEV}/${STUBS_BUILDROOT}}
		export BUILDTEMP=${BUILDTEMP}
		export BUILDMODE=${BUILDMODE}
		export INSTTEMP=${STUBS_INSTTEMP+${TOPLEV}/${STUBS_INSTTEMP}}
		export SOURCETREE=${STUBS_SOURCETREE+${TOPLEV}/${STUBS_SOURCETREE}}
		export TCTREE=${STUBS_TCTREE+${TOPLEV}/${STUBS_TCTREE}}
		export TARGET_CPU=${PROJECT_TARGET_CPU}

		( cd ${BUILDTEMP} || exit 1
			[ -d ${TCTREE}/bin ] && PATHPFX=${TCTREE}/bin:
			[ -d ${TCTREE}/usr/bin ] && PATHPFX=${PATHPFX}${TCTREE}/usr/bin:
			[ -d ${TCTREE}/sbin ] && PATHPFX=${PATHPFX}${TCTREE}/sbin:
			[ -d ${TCTREE}/usr/sbin ] && PATHPFX=${PATHPFX}${TCTREE}/usr/sbin:
			PATH=${PATHPFX}${PATH} make -f build.mak ${BUILDMODE}
		) || exit 1
	;;
	*)	echo "*** package.sh do_pkgconf_build_make(): Unexpected BUILD_METHOD ${BUILD_METHOD} ***" 1>&2
		# LEGACY ... ( cd ${BUILDTEMP}/source && eval "PATH=${REQPATH} SYSCONF=${SYSCONF} PKGFILE=${PKGCFG} INSTTEMP=${INSTTEMP} ${INSTDIRS} ${BUILDSH} $*" && cd - && do_trackinst ${PKGNAME} ${PKGVER}${PKGREV} )
		exit 1
	;;
	esac
}

pkgconf_build_package()
{
	PKGDIR=$1
	BUILDMODE=$2
	PKGCONF=$3

	if [ -z "${PKGDIR}" ] ; then
		echo "*** $0: pkgconf_build_package(): Bad PKGDIR ${PKGDIR}: Argument missing ***" 1>&2
		exit 1
	else
		pkgconf_emit_details checkdirs ${PKGDIR}/${PKGCONF}

		# SYSCONF/PKGFILE, if the build script can't see them:
		stubs_envfile_load

		# initialise: assume legacy mode unless overridden
		BUILD_METHOD=LEGACY
		SRCXPATH=
		. ${PKGDIR}/${PKGCONF} || exit 1

		echo "<<< ${PKGNAME} v${PKGVER}${PKGREV}, BUILD_METHOD ${BUILD_METHOD} BUILDMODE ${BUILDMODE} >>>"

		# Create package-specific build tree
		BUILDTEMP=${TOPLEV}/${STUBS_BUILDROOT}/${BUILDMODE}-${PKGNAME}-${PKGVER}${PKGREV}
		echo "...BUILDTEMP ${BUILDTEMP} FROM PKGDIR ${PKGDIR}..."
		mkdir -p ${BUILDTEMP}

		# FUTURE: BUILD_METHOD could be 'MAKEFILE'
		case ${BUILD_METHOD} in
		SCRIPT)
			# TODO: VERSION in 'build.sh' filename?
			cp ${PKGDIR}/${PKGCONF} ${BUILDTEMP}/package.cfg
			if [ -r ${PKGDIR}/v${PKGVER}${PKGREV}.sh ] ; then
				cp ${PKGDIR}/v${PKGVER}${PKGREV}.sh ${BUILDTEMP}/build.sh || exit 1
			else
				cp ${PKGDIR}/build.sh ${BUILDTEMP}/build.sh || exit 1
			fi
		;;
		MAKEFILE)
			cp ${PKGDIR}/${PKGCONF} ${BUILDTEMP}/package.cfg
			if [ -r ${PKGDIR}/v${PKGVER}${PKGREV}.mak ] ; then
				cp ${PKGDIR}/v${PKGVER}${PKGREV}.mak ${BUILDTEMP}/build.mak || exit 1
			else
				cp ${PKGDIR}/build.mak ${BUILDTEMP}/build.mak || exit 1
			fi
		;;
		*)	echo "package.sh pkgconf_build_package(): Unexpected BUILD_METHOD ${BUILD_METHOD}"
			exit 1
		;;
		esac

		do_pkgconf_build_init || exit 1
		do_pkgconf_build_make || exit 1

		[ "${CLEAN}" = 'n' ] || rm -rf ${BUILDTEMP}
	fi
}
