#!/bin/sh
# 05/09/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
	if [ -r ${TCTREE}/${FR_UCPATH}/bin/i386-uclibc-linux-gnu-gcc ] ; then
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/i386-uclibc-linux-gnu-gcc
	else
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-gcc
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/ s/gcc/${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
			| sed '/^INSTALLDIR/ s/DESTDIR/prefix/' \
			| sed 's/-[og] root//g' \
			> ${MF} || exit 1
	done || exit 1

	[ -r dd_rescue.c.OLD ] \
		|| mv dd_rescue.c dd_rescue.c.OLD || exit 1
	cat dd_rescue.c.OLD \
		| sed '/define _FILE_OFFSET_BITS/ s/64/32/' \
		> dd_rescue.c || exit 1

# BUILD...
	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		  || exit 1

# INSTALL...
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
