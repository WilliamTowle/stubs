#!/bin/sh
# 19/12/2005

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

	case ${PKGVER} in
	0.15.0)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		# can't set CC, glib build will fail. Yak!
		  ac_cv_func_setresuid=no \
		  glib_cv_va_copy=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			 --disable-largefile --disable-nls \
			 || exit 1
		;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit
		;;
	esac

# | sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
	for MF in Makefile glib-1.2.8/Makefile ; do
		[ -r $MF.OLD ] || mv $MF $MF.OLD || exit 1
		cat $MF.OLD \
			| sed '/^CC *=/ s%g*cc$%'${FR_CROSS_CC}'%' \
			> $MF || exit 1
	done

# BUILD...
##	PATH=${FR_LIBCDIR}/bin:${PATH}
#		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` || exit 1
	make || exit 1

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

	CC=${FR_HOST_CC} \
	./configure --prefix=/usr \
	  --host=`uname -m` --build=${TARGET_CPU} \
	  --disable-largefile --disable-nls \
	  || exit 1

## | sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
#	for MF in Makefile glib-1.2.8/Makefile ; do
#		[ -r $MF.OLD ] || mv $MF $MF.OLD || exit 1
#		cat $MF.OLD \
#			| sed '/^CC *=/ s%g*cc$%'${FR_HOST_CC}'%' \
#			> $MF || exit 1
#	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#		make CCPREFIX=`echo ${FR_HOST_CC} | sed 's/cc$//'` \
#		  || exit 1
	make || exit 1

# INSTALL...
	 make DESTDIR=${INSTTEMP} install || exit 1
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
