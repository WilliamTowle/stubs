#!/bin/sh
# 13/11/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
	if [ -r ${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc ] ; then
		# original sane-gcc-compiler environment
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	elif [ -r ${TCTREE}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc ] ; then
		# sane-gcc-compiler environment, 09/10/2004
		FR_CROSS_CC=${TCTREE}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc
		FR_LIBCDIR=${TCTREE}
	else
		# uClibc-wrapper build environment
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
			> ${MF} || exit 1
	done \
		|| exit 1

# BUILD...
	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
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
	exit 1
	;;
esac
