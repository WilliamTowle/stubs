#!/bin/sh
# 2008-03-28 (prev 2006-06-07)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	2.19)
		if [ -d ${PKGNAME}-${PKGVER} ] ; then
			for PF in *patch ; do
				patch --batch -d ${PKGNAME}-${PKGVER} -Np1 < ${PF} || exit 1
			done
			cd ${PKGNAME}-${PKGVER}
		fi
	;;
	esac

	case ${PHASE} in
	dc)
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
	th)
		CC=${FR_HOST_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  || exit 1
	;;
	*)	echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

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
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCDEPMODE='depmode=pch' || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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

	PHASE=th do_configure || exit 1

	# (07/03/2006) install-info broken on Knoppix 3.3
	find ./ -name [Mm]akefile | while read MF ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	.*--info-dir/	s/install-info/true/' \
			> ${MF} || exit 1
	done

# BUILD...
	make

# INSTALL...
	make install
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
