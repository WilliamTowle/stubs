#!/bin/sh -x
# 2007-11-24

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER}-${PHASE} in
	0.14.6-dc)
		CC=${FR_CROSS_CC} \
		    CFLAGS='-O2' \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
			  || exit 1
	;;
	0.14.6-tc)
		CC=${FR_CROSS_CC} \
		    CFLAGS='-O2' \
			./configure --prefix=/usr --libdir=/lib \
			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
			  || exit 1
	;;
	0.14.6-th)
		CC=${FR_HOST_CC} \
		    CFLAGS='-O2' \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  --host=`uname -m` --build=`uname -m` \
			  || exit 1
	;;
	0.17-tc)
		CC=${FR_CROSS_CC} \
		    CFLAGS='-O2' \
			./configure --prefix=/usr --libdir=/lib \
			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
			  --without-csharp \
			  --with-included-gettext \
			  --disable-asprintf \
			  || exit 1
	;;
#	0.15)
#		  CC=${FR_CROSS_CC} \
#		    CCC=`echo ${FR_CROSS_CC} | sed 's/cc$/++/'` \
#		    CFLAGS='-O2' \
#			./configure --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
#			  --with-included-gettext \
#			  --with-libintl-prefix=${FR_LIBCDIR} \
#			  --with-libiconv-prefix=${FR_LIBCDIR} \
#			  --without-csharp \
#			  --without-libpth-prefix \
#			  --disable-asprintf \
#			  --disable-nls \
#			  --disable-static \
#			  --disable-threads \
#			  || exit 1
#	;;
##	0.17)
##		  CC=${FR_CROSS_CC} \
##		    CCC=`echo ${FR_CROSS_CC} | sed 's/cc$/++/'` \
##		    CFLAGS="-O2 -DNO_LARGEFILE_SOURCE" \
##			./configure --prefix=/usr \
##			  --host=`uname -m` --build=${TARGET_CPU} \
##			  --with-included-gettext \
##			  --with-libintl-prefix=${FR_LIBCDIR} \
##			  --with-libiconv-prefix=${FR_LIBCDIR} \
##			  --disable-largefile \
##			  --disable-nls \
##			  --disable-threads \
##			  || exit 1
##	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
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

	PHASE=dc do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr
	make prefix=${INSTTEMP}/usr install || exit 1
}

make_tc()
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

	( cd gettext-runtime || exit 1
	PHASE=tc do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	0.14.6)
		make || exit 1
	;;
	0.17)
		make CC=${FR_CROSS_CC} -C intl || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	0.14.6)
		make DESTDIR=${FR_LIBCDIR} install || exit 1
	;;
	0.17)
		make -C intl DESTDIR=${FR_LIBCDIR} install || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
	) || exit 1
}

make_th()
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

	PHASE=th do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	mkdir -p ${FR_TH_ROOT}/usr
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
