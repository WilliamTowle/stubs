#!/bin/sh
# 26/09/2005

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
	fi
# GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	if [ -r ./configure ] ; then
		echo "$0: CONFIGURE: Unexpected ./configure" 1>&2
		exit 1
	fi

	[ -r Makefile.cnf.OLD ] || mv Makefile.cnf Makefile.cnf.OLD || exit 1
	cat Makefile.cnf.OLD \
		| sed '/^CC=/	s%gcc%'${FR_CROSS_CC}'%' \
		| sed 's/DIR=/DIR=${DESTDIR}/' \
		> Makefile.cnf || exit 1

	[ -r pcspk.c.OLD ] || mv pcspk.c pcspk.c.OLD || exit 1
	cat pcspk.c.OLD \
		| sed 's/lrint/ceil/' \
		> pcspk.c || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/local/sbin || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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
