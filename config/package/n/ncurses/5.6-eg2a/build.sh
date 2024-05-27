#!/bin/sh
# 07/01/2007

# (31/07/2006) problems linking with ncurses?

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		case ${PKGVER} in
		5.5)
			for PF in *patch ; do
				cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
			done
		;;
		esac
		cd ${PKGNAME}-${PKGVER}
	fi

	case ${PHASE} in
	dc)
		CC=${FR_CROSS_CC} \
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
		  ac_cv_func_nanosleep=no \
		  ac_cv_func_setvbuf_reversed=no \
		  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --with-build-cc=${FR_HOST_CC} \
			  --with-build-cflags='' --with-build-ldflags='' \
			  --with-build-libs='' \
			  --without-ada --without-debug --without-cxx-binding \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
	th)
		CC=${FR_CROSS_CC} \
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
		  ac_cv_func_nanosleep=no \
		  ac_cv_func_setvbuf_reversed=no \
		  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
			  --host=${FR_HOST_DEFN} \
			  --with-build-cc=${FR_HOST_CC} \
			  --with-build-cflags='' --with-build-ldflags='' \
			  --with-build-libs='' \
			  --without-ada --without-debug --without-cxx-binding \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac
}

do_install()
{
	case ${PHASE} in
	dc)
		make DESTDIR=${INSTTEMP} install.libs || exit 1
		make DESTDIR=${INSTTEMP} install.data || exit 1
	;;
	tc)
		make prefix=${FR_LIBCDIR} install.libs || exit 1
		make prefix=${FR_LIBCDIR} install.data || exit 1
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

	PHASE=dc do_configure || exit 1

# BUILD...
	make all || exit 1

# INSTALL...
	PHASE=dc do_install
}

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

	PHASE=th do_configure || exit 1

# BUILD...
	make all || exit 1

# INSTALL...
	PHASE=tc do_install
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
