#!/bin/sh
# 17/03/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
		echo "$0: Aborting -- no 'fakeroot'" 1>&2
		exit 1
	fi

#	# USE_SYSTEM_PWD_GROUP should be 'true' for uClibc <= 0.9.15
#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done

	case ${PKGVER} in
	0.80|1.2)
		[ -r passwd.c.OLD ] || mv passwd.c passwd.c.OLD || exit 1
		cat passwd.c.OLD \
			| sed 's/n""$/n"/' \
			| sed 's/ Please use/ "Please use/' \
			> passwd.c || exit 1
	;;
	1.4)
		[ -r Config.h.OLD ] || mv Config.h Config.h.OLD || exit 1
		cat Config.h.OLD \
			| sed '/define CONFIG_VLOCK/ s%^%//%' \
			| sed '/define CONFIG_FEATURE_SHA1_PASSWORDS/ s%^%//%' \
			> Config.h || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...

		make CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		  || exit 1

# INSTALL...
#	${FR_TH_ROOT}/usr/bin/fakeroot \
#		-- make PREFIX=${INSTTEMP} install || exit 1
	make PREFIX=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
