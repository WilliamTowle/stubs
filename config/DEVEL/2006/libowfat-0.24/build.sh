#!/bin/sh
# 06/10/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ -r ./configure ] ; then
		echo "$0: CONFIGURE: Unexpected ./configure" 1>&2
		exit 1
	fi
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#	  CFLAGS="-O2" \
#		./configure --prefix=${FR_LIBCDIR} \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  || exit 1

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name "*[Mm]akefile"` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^DIET/		s/D/#D/' \
			| sed '/^CC *=/		s%gcc%'${FR_CROSS_CC}'%' \
			| sed '/^CFLAGS *=/	s/ -g / /' \
			| sed '/^prefix *=/	s%/.*%'${FR_LIBCDIR}'/owfat/%' \
			> ${MF} || exit 1
	done

	for SF in trysendfile.c io/io_readfile.c io/io_appendfile.c \
		io/io_sendfile.c io/io_createfile.c \
		io/io_readwritefile.c \
		open/open_append.c open/open_excl.c open/open_read.c \
		open/open_rw.c open/open_trunc.c open/open_write.c ; do

		[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed '/define _FILE_OFFSET_BITS/ s/64/32/' \
			> ${SF} || exit 1
	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	make DESTDIR='' install || exit 1
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#	;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
