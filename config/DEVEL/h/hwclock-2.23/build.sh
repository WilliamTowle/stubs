#!/bin/sh
# 13/03/2005

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

#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls --disable-largefile \
#		  || exit 1

## | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			| sed '/^CFLAGS/ s/-g//' \
#			| sed '/^prefix/ s%/%${DESTDIR}/%' \
#			| sed '/^all:/ s/ info / /' \
#			| sed '/^all:/ s/ dvi$/ /' \
#			| sed '/^install:/ s/install-info//' \
#			| sed '/^	/ s/-o $(UID)//' \
#			| sed '/^	/ s/-g $(GID)//' \
#			| sed '/:/ s%/usr/include/linux%'${FR_LIBCDIR}/include/linux'%' \
		cat ${MF}.OLD \
			| sed '/^CC/ s%gcc%'${FR_CROSS_CC}'%' \
			> ${MF} || exit 1
	done || exit 1

# BUILD...
	( cd src || exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

	) || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/sbin || exit 1
	cp src/hwclock ${INSTTEMP}/usr/local/sbin/ || exit 1
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