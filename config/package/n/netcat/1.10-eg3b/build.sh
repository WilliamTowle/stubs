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

	[ -r netcat.c.OLD ] || mv netcat.c netcat.c.OLD || exit 1
	cat netcat.c.OLD \
		| sed 's%#define HAVE_BIND%/* #define HAVE_BIND */%' \
		> netcat.c || exit 1

# | sed '/^CC/ s/cc/${CCPREFIX}cc/' \
# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC/ s%g*cc%'${FR_CROSS_CC}'%' \
		> Makefile || exit 1

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g `uname -s | tr A-Z a-z` || exit 1
	make `uname -s | tr A-Z a-z` || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/sbin || exit 1
	cp nc ${INSTTEMP}/usr/sbin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/local/netcat-scripts || exit 1
	cp -r scripts* ${INSTTEMP}/usr/local/netcat-scripts/ || exit 1
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
