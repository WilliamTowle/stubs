#!/bin/sh
# 01/01/2005

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
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/ s/gcc/${CCPREFIX}cc/' \
			| sed '/^INSTALLDIR/ s%/%/${DESTDIR}/%' \
			> ${MF} || exit 1
	done || exit 1

# A lot of the commenting is bobbinsed
	[ -r unarj.h.OLD ] || mv unarj.h unarj.h.OLD || exit 1
	cat unarj.h.OLD \
		| sed '/^ \*/ s%^%/* %' \
		| sed '/^\/\*/ s%$% */%' \
		| sed '/^\/\*/ s%\*\/ %%' \
		> unarj.h || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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
