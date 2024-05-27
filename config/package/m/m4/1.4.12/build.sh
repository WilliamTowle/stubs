#!/bin/sh
# 2008-10-16

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			patch --batch -d ${PKGNAME}-${PKGVER} -Np1 < ${PF} || exit 1
		done
		cd ${PKGNAME}-${PKGVER}
	fi

	case ${PHASE}-${PKGVER} in
	dc-1.4.[5678]|dc-1.4.1[012])
		  CC=${FR_CROSS_CC} \
		    CFLAGS=-O2 \
		    ac_cv_path_install=${FR_TH_ROOT}/bin/install \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-nls --disable-largefile \
			  || exit 1

		[ -r lib/regcomp.c.OLD ] || mv lib/regcomp.c lib/regcomp.c.OLD || exit 1
		cat lib/regcomp.c.OLD \
			| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
			> lib/regcomp.c || exit 1
	;;
	th-*)
		CC=${FR_HOST_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=${FR_TH_ROOT}/usr \
			   || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	case ${PHASE}-${FR_TARGET_DEFN} in
	dc*uclibc*|dc*earlgrey*)
		for SF in freadahead.c freading.c fseeko.c ; do
			[ -r lib/${SF}.OLD ] || mv lib/${SF} lib/${SF}.OLD || exit 1
			cat lib/${SF}.OLD \
				| sed 's/__modeflags/modeflags/' \
				| sed 's/__bufpos/bufpos/' \
				| sed 's/__bufread/bufread/' \
				| sed 's/__bufstart/bufstart/' \
				| sed 's%def __STDIO_BUFFERS% 0 /* __STDIO_BUFFERS */%' \
				> lib/${SF} || exit 1
		done
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

	PHASE=dc do_configure

# BUILD...
	make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr exec_prefix=${INSTTEMP}/usr install || exit 1
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

	PHASE=th do_configure

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
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
