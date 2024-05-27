#!/bin/sh
# tar v1.13-fr1a		STUBS (c) and GPLv2 1999-2010
# last modified			2010-11-21

#[ "${SYSCONF}" ] && . ${SYSCONF}
#[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ ! -d source ] ; then
		echo "No 'source' - extract failed?"
		exit 1
	else
		cd source || exit 1
	fi

# mktime test slow on recent systems
	ac_cv_func_working_mktime=no \
	CC=${FR_HOST_CC} \
		./configure \
			--prefix=${FR_TH_ROOT}/usr --bindir=${FR_TH_ROOT}/bin \
			--build=${FR_HOST_SYS} --host=${FR_HOST_SYS} \
			--disable-largefile --disable-nls \
			|| exit 1
}

#make_dc()
#{
## CONFIGURE...
#	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
#		# Ah, sanity! 2005-11-11 onward
#		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
#	else
##		echo "$0: CONFIGURE: Configuration not determined" 1>&2
#		if [ -d ${TCTREE}/cross-utils ] ; then
#			FR_TC_ROOT=${TCTREE}/cross-utils
#			FR_TH_ROOT=${TCTREE}/host-utils
#		else
#			FR_TC_ROOT=${TCTREE}/
#			FR_TH_ROOT=${TCTREE}/
#		fi
#
#		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
#		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
#		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
#			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
#		else
#			FR_HOST_CC=`which gcc`
#		fi
#		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
#	fi
#
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr  --bindir=/bin \
#		 --host=`uname -m` --build=${TARGET_CPU} \
#		 --libexecdir=/usr/bin \
#		 --disable-largefile --disable-nls || exit 1
#
## | sed '/^INCLUDES/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
#	for MF in Makefile */Makefile ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/-g //' \
#			> ${MF} || exit 1
#	done
#
## BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#		make \
#		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc/ar/'` \
#		  || exit 1
#
## INSTALL...
#	make prefix=${MINIMAL_INSTTEMP}/usr bindir=${MINIMAL_INSTTEMP}/bin libexecdir=${MINIMAL_INSTTEMP}/usr/bin install || exit 1
#
#	mkdir -p ${UTILS_INSTTEMP}/usr || exit 1
#	rm -rf ${UTILS_INSTTEMP}/usr/bin 2>/dev/null
#	mv ${MINIMAL_INSTTEMP}/usr/bin ${UTILS_INSTTEMP}/usr/ || exit 1
#}
#
#make_th()
#{
## CONFIGURE...
#	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
#		# Ah, sanity! 2005-11-11 onward
#		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
#	else
##		echo "$0: CONFIGURE: Configuration not determined" 1>&2
#		if [ -d ${TCTREE}/cross-utils ] ; then
#			FR_TC_ROOT=${TCTREE}/cross-utils
#			FR_TH_ROOT=${TCTREE}/host-utils
#		else
#			FR_TC_ROOT=${TCTREE}/
#			FR_TH_ROOT=${TCTREE}/
#		fi
#
#		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
#		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
#		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
#			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
#		else
#			FR_HOST_CC=`which gcc`
#		fi
#		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
#	fi
#
### ...tries to use 'cc' by default. Assume cc != gcc:
#	CC=${FR_HOST_CC} ./configure --prefix=${FR_TH_ROOT} \
#		--disable-largefile --disable-nls || exit 1
#}

handle_nti()
{
# CONFIGURE...
	# basic NTI/NUI setup
	FR_HOST_CC=/usr/bin/gcc
	FR_HOST_CPU=`uname -m | sed 's/x86_64/i686/'`
	FR_HOST_SYS=${FR_HOST_CPU}-unknown-linux-gnu
	FR_TH_ROOT=${TCTREE}

	do_configure || exit 1

# BUILD...
	#echo "..." ; exit 1
	make || exit 1

# INSTALL...
	#echo "..." ; exit 1
	make install || exit 1
}


##
##	main program
##

BUILDMODE=$1
[ "$1" ] && shift
case ${BUILDMODE} in
NTI)		## native toolchain install
	handle_nti $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDMODE '${BUILDMODE}'" 1>&2
	exit 1
;;
esac
