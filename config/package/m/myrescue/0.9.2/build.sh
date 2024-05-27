#!/bin/sh
# 12/12/2004

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

#	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-largefile --disable-nls \
#		  || exit 1

	cat src/myrescue.c \
		| sed 's/lseek64/lseek/' \
		| sed 's/open64/open/' \
		> myrescue.c || exit 1

# BUILD...
	case ${PKGVER} in
	0.9.2)
		${FR_CROSS_CC} myrescue.c -o myrescue || exit 1
		;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 2>&1
		exit 1
		;;
#	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
#		make || exit 1
	esac \
		|| exit 1


# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	cp myrescue ${INSTTEMP}/usr/local/bin || exit 1
	#make DESTDIR=${INSTTEMP} install || exit 1
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
