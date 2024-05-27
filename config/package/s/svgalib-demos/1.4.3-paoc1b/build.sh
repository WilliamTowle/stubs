#!/bin/sh
# 22/08/2006

#TODO:- (16/01/2005) threeDKit wants to 'chown root ...'

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

	if [ -d svgalib-${PKGVER} ] ; then
		cd svgalib-${PKGVER} || exit 1
		case ${PKGVER} in
		1.4.3)
			for PF in ../svgalib*patch ; do
				cat ${PF} | patch -Np1 -i - || exit 1
			done
#		for PF in ../${PKGNAME}*diff.gz ; do
#			zcat ${PF} | patch -Np1 -i - || exit 1
#		done
		;;
		*)
			echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
			exit 1
		;;
		esac
	fi


	# setting 'CC' doesn't work
	[ -r Makefile.cfg.OLD ] \
		|| mv Makefile.cfg Makefile.cfg.OLD || exit 1
	cat Makefile.cfg.OLD \
		| sed '/^	CC/ s%gcc%'${FR_CROSS_CC}'%' \
		| sed '/^INCLUDE_FBDEV_DRIVER/ s/^/#/' \
		| sed '/^prefix/ s%/usr/local%%' \
		| sed '/^INSTALL_/ s/-o root//' \
		| sed '/^INSTALL_/ s/-g bin//' \
		> Makefile.cfg || exit 1

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	chown root/ s/^/#/' \
			| sed 's%@ldconfig%-'${TCTREE}'/usr/sbin/ldconfig%' \
			> ${MF} || exit 1
	done || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CC=${FR_CROSS_CC} \
		  demoprogs \
		  || exit 1

# INSTALL...
	#make TOPDIR=${INSTTEMP} install || exit 1
	mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
	cp demos/fun ${INSTTEMP}/usr/local/bin || exit 1
	#...not 1.4.3?
	#cp demos/vgatest ${INSTTEMP}/usr/local/bin || exit 1
	cp threeDKit/plane ${INSTTEMP}/usr/local/bin || exit 1
	cp threeDKit/wrapdemo ${INSTTEMP}/usr/local/bin || exit 1
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
