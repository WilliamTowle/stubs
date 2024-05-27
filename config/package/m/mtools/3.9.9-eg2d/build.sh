#!/bin/sh
# 07/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PHASE} in
	dc)
		# 2008-02-04: no support for build=FR_TARGET_DEFN
		  CC=${FR_CROSS_CC} \
		  ac_cv_func_setpgrp_void=yes \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --with-x=no \
			  || exit 1
	;;
	th)
		  CC=${FR_HOST_CC} \
		  ac_cv_func_setpgrp_void=yes \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  --host=${FR_HOST_DEFN} --build=${FR_HOST_DEFN} \
			  --disable-nls --disable-largefile \
			  --with-x=no \
			  || exit 1
	;;
	*)
		echo "$0: do_configure(): Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	esac

	MI=`which makeinfo 2>/dev/null`
	if [ -z "$MI" ] ; then
		sed 's/ install-info//' Makefile > Makefile.OLD || exit 1
	else
		mv Makefile Makefile.OLD || exit 1
	fi
	if [ "${PHASE}" == 'tc' ] ; then
		cat Makefile.OLD \
			| sed '/^CFLAGS/ s/ -g //' \
			> Makefile || exit 1
	else
		cat Makefile.OLD \
			| sed 's/CPU_'`uname -m`'/CPU_'${TARGET_CPU}'/' \
			| sed '/^CFLAGS/ s/ -g //' \
			> Makefile || exit 1
	fi
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

	PHASE=dc do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	PHASE=th do_configure || exit 1

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
