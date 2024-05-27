#!/bin/sh
# 20/01/2005

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

	if [ ! -r ${TCTREE}/${FR_UCPATH}/include/pcap.h ] ; then
		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
		exit 1
	fi

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  ac_cv_func_malloc_nonnull=yes \
	  CC=${FR_CROSS_CC} \
	  CFLAGS="-O2" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

	# don't use replacement malloc
	[ -r src/config.h.OLD ] \
		|| mv src/config.h src/config.h.OLD || exit 1
	cat src/config.h.OLD \
		| sed '/define malloc/ s%^%/* %' \
		| sed '/define malloc/ s%$% */%' \
		> src/config.h || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make prefix=${INSTTEMP}/usr install || exit 1
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
