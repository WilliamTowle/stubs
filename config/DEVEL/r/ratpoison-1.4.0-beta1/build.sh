#!/bin/sh
# 27/01/2005

#TODO:- "configure: error: *** Can't find History headers and libs"
#TODO:- works, but "can't load library 'libX11.so.6'" at runtime

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

	if [ ! -r ${FR_LIBCDIR}/include/readline/readline.h ] ; then
		echo "$0: Confused -- no readline.h" 1>&2
		exit 1
	else
		ADD_INCL_READLINE='-I'${FR_LIBCDIR}'/readline'
	fi || exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	  CFLAGS=-O2 \
		./configure --prefix=/usr --libexecdir=/usr/bin \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

## | sed '/^INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include '${ADD_INCL_READLINE}' -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make all || exit 1

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
