#!/bin/sh
# 17/01/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	1.27)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed 's/^CC=.*/CC=${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/ -g //' \
			| sed "s/-march=[a-z0-9]*/-march=${TARGET_CPU}/" \
			> Makefile || exit 1
		;;
	1.50)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed 's/^CC=.*/CC=${CCPREFIX}cc/' \
			| sed '/^CCFLAGS/ s/ -m32 / /' \
			| sed '/^	/ s/ -g / /' \
			| sed '/^	/ s/ -m32 / /' \
			| sed '/^AS/ s%as%'`echo ${FR_HOST_CC} | sed 's/gcc$/as/'`'%' \
			| sed "s/-march=[a-z0-9]*/-march=${TARGET_CPU}/" \
			> Makefile || exit 1
		;;
	1.70)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed 's/^C=.*/CC=${CCPREFIX}cc/' \
			| sed '/^CCFLAGS/ s/ -m32 / /' \
			| sed '/^	/ s/ -g / /' \
			| sed '/^	/ s/ -m32 / /' \
			| sed '/^AS/ s%as%'`echo ${FR_CROSS_CC} | sed 's/gcc$/as/'`'%' \
			| sed "s/-march=[a-z0-9]*/-march=${TARGET_CPU}/" \
			> Makefile || exit 1
		;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac
}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/usr/host-utils/bin/gcc ] ; then
		FR_HOST_CC=${TCTREE}/usr/host-utils/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	do_configure || exit 1

# BUILD...
	make CCPREFIX=`echo ${FR_HOST_CC} | sed 's/cc$//'` || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/lib/${PKGNAME} || exit 1
	cp memtest.bin ${INSTTEMP}/usr/lib/${PKGNAME}
}

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
