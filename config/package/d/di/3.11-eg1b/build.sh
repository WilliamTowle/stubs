#!/bin/sh
# 23/04/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	if [ -r ${TCTREE}/usr/host-linux/bin/gcc ] ; then
		FR_HOST_CC=${TCTREE}/usr/host-linux/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	[ -r Configure.OLD ] || mv Configure Configure.OLD || exit 1
	cat Configure.OLD \
		| sed "s%'./try'%'test -r ./try'%" \
		> Configure || exit 1

	# Can't use cross compiler if executables won't run natively
	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  CFLAGS='-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include' \
		./configure --prefix=/usr \
		  || exit 1

	for SF in config.h di.c di.h dilib.c ; do
		[ -r ${SF}.OLD ] || mv $SF ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed '/^#define SIZ_LONG_LONG/ s%/\*%%' \
			| sed '/^#define SIZ_LONG_LONG/ s%^%/* %' \
			| sed 's/_(/_ARGS(/' \
			| sed '/define _enable_nls/ s%1%0 /* 1 */%' \
			> ${SF} || exit 1
	done || exit 1

	mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC / s/=.*/= ${CCPREFIX}cc/' \
		| sed 's%-[IL]/usr/local/include%%' \
		| sed 's%= /usr%= ${DESTDIR}/usr%' \
		| sed '/^MANDIR/ s%local/%%' \
		| sed '/^MANDIR/ s%share/%%' \
		> Makefile || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_tc || exit 1
#	;;
*)
	exit 1
	;;
esac
