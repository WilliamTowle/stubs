#!/bin/sh
# 17/12/2005

#EXCLUDES="bin/bzless bin/bzmore bin/bzip2recover usr/bin/bzcmp usr/bin/bzdiff usr/bin/bzgrep usr/bin/bzegrep usr/bin/bzfgrep"

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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	for MF in `find ./ -name "[Mm]akefile*"` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
	done

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#		| sed '/^PREFIX/ s%/usr%${DESTDIR}/usr%' \
	# there are two available Makefiles
	cat Makefile.OLD \
		| sed '/^CC=/ s%gcc%'${FR_CROSS_CC}'%' \
		| sed '/^BIGFILES/ s/^/#/' \
		| sed '/^	/ s%$(PREFIX)%${DESTDIR}/${PREFIX}%' \
		> Makefile || exit 1

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g \
#		  RANLIB=${TARGET_CPU}-uclibc-ranlib \
#		  libbz2.a \
#		  || exit 1
	make \
	  RANLIB=`echo ${FR_CROSS_CC} | sed 's/gcc$/ranlib/'` \
	  libbz2.a \
	  || exit 1

# INSTALL...
	mkdir -p ${FR_LIBCDIR}/lib/ || exit 1
	cp bzlib.h ${FR_LIBCDIR}/include || exit 1
	cp libbz2.a ${FR_LIBCDIR}/lib || exit 1
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
