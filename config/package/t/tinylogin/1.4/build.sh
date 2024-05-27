#!/bin/sh
# 11/10/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-cross-linux-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi
# GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	if [ ! -r ${TCTREE}/usr/bin/fakeroot ] ; then
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
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		  || exit 1

# INSTALL...
	${TCTREE}/usr/bin/fakeroot \
		-- make PREFIX=${INSTTEMP} install || exit 1
}

#make_th()
#{
#}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
