#!/bin/sh
# 06/09/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_tweak_source()
{
	GCCVER=`${FR_HOST_CC} -v 2>&1 | grep 'version' | sed 's/gcc version //'`
		# want to set HOSTCC to ${FR_HOST_CC}
		# but something goes inconsistent (31/05/2004)
	[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1
	case ${GCCVER} in
	2.7.2.3)	# ditto 2.8.1
		cat Rules.mak.OLD \
			| sed '/preferred-stack-boundary/ s/^/#/' \
			| sed 's/-fno-strict-aliasing//' \
			| sed '/^HOSTCFLAGS=/ s/-O2 //' \
			| sed '/usr.bin.*awk/ s%/usr/bin%'${FR_TH_ROOT}'/usr/bin%' \
			> Rules.mak || exit 1
		;;
	*)	# possibly remove -fno-strict-aliasing for 2.95.3/3.x?
		cat Rules.mak.OLD \
			| sed '/usr.bin.*awk/ s%/usr/bin%'${FR_TH_ROOT}'/usr/bin%' \
			> Rules.mak || exit 1
		;;
	esac

	for MF in libc/sysdeps/linux/*/Makefile ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's/-g,,/-g , ,/' \
			> ${MF} || exit 1
	done

	[ -r extra/gcc-uClibc/Makefile.OLD ] \
		|| cp extra/gcc-uClibc/Makefile extra/gcc-uClibc/Makefile.OLD || exit 1
	case ${PHASE} in
	dc)
		cat extra/gcc-uClibc/Makefile.OLD \
			| sed 's/HOSTC/C/' \
			| sed '/^GCC_BIN/ s%=.*%='${TARGET_CPU}'-uclibc-gcc%' \
			| sed 's/(CC) /(GCC_BIN) /' \
			| sed '/^GCCINCDIR/ s/(CC)/(GCC_BIN)/' \
			| sed '/APPNAME=/ s%which%'${TCTREE}'/usr/bin/which%' \
			> extra/gcc-uClibc/Makefile || exit 1
		;;
	th)
		cat extra/gcc-uClibc/Makefile.OLD \
			| sed 's/HOSTC/C/' \
			| sed '/^GCC_BIN/ s%=.*%='${FR_HOST_CC}'%' \
			| sed 's/(CC) /(GCC_BIN) /' \
			| sed '/^GCCINCDIR/ s/(CC)/(GCC_BIN)/' \
			| sed '/APPNAME=/ s%which%'${TCTREE}'/usr/bin/which%' \
			> extra/gcc-uClibc/Makefile || exit 1
		;;
	esac

	case ${GCCVER} in
	2.7.2.3|2.8.1)	# lacks stdbool.h - ditto 2.8.1
		for FILE in extra/config/expr.h extra/config/zconf.tab.c_shipped ; do
			[ -r ${FILE}.OLD ] || mv ${FILE} ${FILE}.OLD || exit 1
		done
		cat extra/config/expr.h.OLD \
			| sed 's/#include <stdbool.h>/typedef enum { false=0, true=1 } bool;/' \
			> extra/config/expr.h || exit 1
		cat extra/config/zconf.tab.c_shipped.OLD \
			| sed '/#include/ s/stdbool.h/expr.h/' \
			> extra/config/zconf.tab.c_shipped || exit 1
		;;
	esac

}

do_configure()
{
	CONFIGDIR=${TCTREE}/etc/`echo ${USE_DISTRO} | sed 's/frlx/freg/'`

	case ${PHASE} in
	dc)	cp ${CONFIGDIR}/uClibc-config-${PKGVER} .config || exit 1
		touch .config
		;;
	th)
		echo -n '' > .config
		# directories for uClibc configuration
		echo 'DEVEL_PREFIX="'${FR_UCPATH}'"' >> .config
		echo 'KERNEL_SOURCE="'${FR_KERNSRC}'"' >> .config
		echo 'SHARED_LIB_LOADER_PATH="/lib"' >> .config
		# standardised .config content (to 17/06/2003)
		echo '# ASSUME_DEVPTS is not set' >> .config
		echo 'MALLOC=y' >> .config
		echo '# MALLOC_930716 is not set' >> .config
		echo 'DO_C99_MATH=y' >> .config
		echo 'UCLIBC_HAS_IPV6=y' >> .config
		echo '# UCLIBC_HAS_LFS is not set' >> .config
		echo 'UCLIBC_HAS_RPC=y' >> .config
		echo 'UCLIBC_HAS_FULL_RPC=y' >> .config
		echo '# UNIX98PTY_ONLY is not set' >> .config
		# 17/07/2004
		case ${PKGVER} in
		0.9.21)
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' >> .config
			;;
		esac

		mkdir -p ${CONFIGDIR} || exit 1
		;;
	esac

	# bring config up to date with everything at default.
	# this process causes the Makefiles to be replaced
	( yes '' | \
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CC=${FR_HOST_CC} HOSTCC=${FR_HOST_CC} \
		oldconfig ) || exit 1

	if [ "${PHASE}" = 'th' ] ; then
		cp .config ${CONFIGDIR}/uClibc-config-${PKGVER} || exit 1
		# (27/06/2004) ...and '-current' link for later study
		( cd ${CONFIGDIR}/ && ln -sf uClibc-config-${PKGVER} uClibc-config-current ) || exit 1
	else	# need not to fail when building distro-cross!
		true
	fi
}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		#FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_LIBCDIR}/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

#	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`
	FR_TARGET=${TARGET_CPU}-linux-uclibc

	PHASE=dc do_tweak_source || exit 1
	PHASE=dc do_configure || exit 1

# BUILD...
# ...setting HOSTCC=${CROSS}-gcc fixes i386-uclibc-ldd:
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		  HOSTCC=${FR_CROSS_CC} \
		  || exit 1

# INSTALL...
	[ -r ${RUNTIME_INSTTEMP} ] && rm -rf ${RUNTIME_INSTTEMP}
	[ -r ${WRAPPERS_INSTTEMP} ] && rm -rf ${WRAPPERS_INSTTEMP}

	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		  HOSTCC=${FR_CROSS_CC} \
		  PREFIX=${WRAPPERS_INSTTEMP} \
		  install || exit 1

	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CROSS=${CROSS_PREFIX}- \
		 PREFIX=${RUNTIME_INSTTEMP} \
		 install_target || exit 1

	mkdir -p ${WRAPPERS_INSTTEMP}/usr/include || exit 1
	( cd ${WRAPPERS_INSTTEMP}/usr/include && ln -sf /usr/${FR_TARGET}/include/* ./ ) || exit 1

	mkdir -p ${WRAPPERS_INSTTEMP}/usr/lib || exit 1
	( cd ${WRAPPERS_INSTTEMP}/usr/lib &&
		ln -s ../../usr/${FR_TARGET}/lib/* ./
	) || exit 1

# (17/04/2005) - seems to use ${WRAPPERS_INSTTEMP}/usr sanely now
## ...handle assumptions made about the toolchain and source-extract
## directory being accessible in the target environment. ld ends up
## calling itself recursively :(
#	( cd ${WRAPPERS_INSTTEMP}/usr/${FR_TARGET}/bin && 
#		cat ${TARGET_CPU}-uclibc-ld \
#			| sed "s%${TCTREE}%%" \
#			| sed "s%/usr/${FR_TARGET}/bin/${TARGET_CPU}-uclibc-%/usr/bin/%" \
#			| sed "s/ *-L[^ ]*$//" \
#			> tmp.$$ &&
#		mv tmp.$$ ${TARGET_CPU}-uclibc-ld &&
#		chmod a+rx ${TARGET_CPU}-uclibc-ld &&

#		find ./ -type l | while read LINK ; do
#			set -- `ls -l ${LINK} | sed 's/[^:]*:.. //'`
#			case $3 in
#			${TARGET_CPU}*) ;;
#			*) ln -sf /usr/bin/`basename $3 | sed 's/.*-//'` $1 ;;
#			esac
#		done
#	) || exit 1

#	( cd ${WRAPPERS_INSTTEMP}/usr/${FR_TARGET}/bin &&
#		find ./ -type l | while read LINK ; do
#			set -- `ls -l ${LINK} | sed 's/[^:]*:.. //'`
#			case $3 in
#			${TCTREE}*) ln -sf /usr/bin/`basename $3 | sed 's/.*-//'` $1 ;;
#			*) ;;
#			esac
#		done
#	) || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -z "${TCTREE}" ] ; then
		echo "$0: Confused: TCTREE unset" 1>&2
		exit 1
	fi
	if [ -d ${TCTREE}/cross-utils ] ; then
		FR_TC_ROOT=${TCTREE}/cross-utils
	else
		FR_TC_ROOT=${TCTREE}
	fi
	if [ -d ${TCTREE}/host-utils ] ; then
		FR_TH_ROOT=${TCTREE}/host-utils
	else
		FR_TH_ROOT=${TCTREE}
	fi

	if [ -d "${FR_TC_ROOT}/usr/src/linux" ] ; then
		# (04/06/2004) use of "i386-linux" -> runtime segfault??!
		#FR_TARGET=${TARGET_CPU}-linux
		FR_TARGET=${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux
		FR_UCPATH=usr/${FR_TARGET}
		FR_LIBCDIR=${FR_TC_ROOT}/${FR_UCPATH}
	elif [ -d "${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc/src/linux" ] ; then
		# (04/06/2004) use of "i386-linux" -> runtime segfault??!
		#FR_TARGET=${TARGET_CPU}-linux
		FR_TARGET=${TARGET_CPU}-linux-uclibc
		#FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux
		FR_UCPATH=usr/${FR_TARGET}
		FR_LIBCDIR=${FR_TC_ROOT}/${FR_UCPATH}
		FR_KERNSRC=${FR_LIBCDIR}/src/linux
	else
		echo "$0: Confused: No kernel headers" 1>&2
		exit 1
	fi

	if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
		FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
#	elif [ -d ${FR_TH_ROOT}/bin/gcc ] ; then
#		FR_HOST_CC=${FR_TH_ROOT}/bin/gcc
	else
		FR_HOST_CC=`which gcc`
		#echo "No host-linux in toolchain" 1>&2
		#exit 1
	fi

	PHASE=th do_tweak_source || exit 1
	PHASE=th do_configure || exit 1

# BUILD...
	make CROSS='' HOSTCC=${FR_HOST_CC} \
		 DEVEL_PREFIX=${FR_LIBCDIR} \
		 || exit 1

# INSTALL...
	make \
		 DEVEL_PREFIX=${FR_LIBCDIR} \
		 install || exit 1

	( cd ${TCTREE}/cross-utils/usr/${FR_TARGET}/usr/bin || exit 1
		for EXE in ar as nm objdump ranlib strip ; do
			ln -s ${TCTREE}/cross-utils/usr/${TARGET_CPU}-cross-linux/bin/${EXE} ./
		done
	) || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
