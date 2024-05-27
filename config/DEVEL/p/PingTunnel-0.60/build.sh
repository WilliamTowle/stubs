#!/bin/sh
# 16/05/2005

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

	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
		exit 1
	fi

#	case ${PKGVER} in
#	0.5.1)
#		[ -r configure.OLD ] || mv configure configure.OLD || exit 1
#		cat configure.OLD \
#			| sed 's/head -1/head -n 1/' \
#			> configure || exit 1
#		chmod a+x configure
#		;;
#	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#		;;
#	esac

#	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
#	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.6.4 and prior
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

	if [ -r ./configure ] ; then
		echo "$0: CONFIGURE: Unexpected ./configure" 1>&2
		exit 1
#		PATH=${TCTREE}/bin:${FR_LIBCDIR}/bin:${PATH} \
#		  ac_cv_func_setvbuf_reversed=no \
#		  ac_cv_file__dev_ptmx=no \
#		  CC=${FR_CROSS_CC} \
#			./configure --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --disable-largefile --disable-nls \
#			  || exit 1
	fi

	find ./ -name Makefile | while read MF ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/	s/gcc/${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-g//' \
			| sed '/^CFLAGS/ s%$%-I'${FR_LIBCDIR}'/include%' \
			| sed '/^LDOPTS/ s%=.*%=-L'${FR_LIBCDIR}'/lib -lpcap -lpthread%' \
			| sed '/^...dir/ s/\$(prefix)/$(INSTTEMP)$(prefix)/' \
			> ${MF} || exit 1
	done

	for SF in ptunnel.h ptunnel.c ; do
		[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed '/#include/	s%sys/unistd.h%unistd.h%' \
			> ${SF} || exit 1
	done

# BUILD...
	# LDFLAGS="-L${FR_LIBCDIR}/lib -lncurses" \
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
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
