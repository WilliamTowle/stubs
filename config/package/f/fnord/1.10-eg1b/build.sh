#!/bin/sh
# 07/12/2005

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

#	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
#		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
#		exit 1
#	fi

	if [ -r ./configure ] ; then
		echo "$0: CONFIGURE: Unexpected ./configure" 1>&2
		exit 1
	fi

#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-largefile --disable-nls \
#		  || exit 1

	if [ -r ./config.h ] ; then
		echo "$0: CONFIGURE: Unexpected ./config.h" 1>&2
		exit 1
	fi
#	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#	cat config.h.OLD \
#		| sed '/define realloc/	s%^%/* %' \
#		| sed '/define realloc/	s%$% */%' \
#		> config.h || exit 1

	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^DIET *=/	s/^/#/' \
		| sed '/^CC *=/	s%g*cc%'${FR_CROSS_CC}'%' \
		> Makefile || exit 1

	# yuk. uClibc 0.9.20 builds sendfile64() and not sendfile(), despite
	# the preference to do otherwise.
	[ -r httpd.c.OLD ] || mv httpd.c httpd.c.OLD || exit 1
	cat httpd.c.OLD \
		| sed '/^#define _FILE_OFFSET_BITS/	s/64/32/' \
		| sed '/if/	s/sendfile/sendfile64/' \
		> httpd.c || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	cp fnord ${INSTTEMP}/usr/local/bin/ || exit 1
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
