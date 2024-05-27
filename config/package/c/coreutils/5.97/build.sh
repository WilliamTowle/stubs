#!/bin/sh
# 07/08/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER}-${PHASE} in
	5.9[467]-th)
#		CC=${FR_HOST_CC} \
#		  ac_list_mounted_fs=no \
#		  gl_cv_list_mounted_fs=no \
#			./configure --prefix=${FR_TH_ROOT} \
#			  CFLAGS='-O2' \
#			  || exit 1
		CC=${FR_HOST_CC} \
		  CFLAGS='-O2' \
		  ac_list_mounted_fs=no \
		  gl_cv_list_mounted_fs=no \
			./configure --prefix=${FR_TH_ROOT} \
			  --without-included-regex \
			  || exit 1
	;;
	5.9[467]-dc)
#		PATH=${FR_LIBCDIR}/bin:${PATH} \
#		  ac_cv_func_getloadavg=no \
#		  CC=${FR_CROSS_CC} \
#		  CFLAGS=-O2 \
#			./configure --prefix=/ \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --disable-largefile --disable-nls \
#			  --disable-rpath --disable-dependency-tracking \
#			  || exit 1
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  ac_cv_func_getloadavg=no \
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=/ \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --disable-rpath --disable-dependency-tracking \
			  --without-included-regex \
			  || exit 1
	;;
	*)
		echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	case ${PKGVER}-${PHASE} in
	5.2.1-dc|5.2.1-th)
		[ -r lib/getdate.y.OLD ] || mv lib/getdate.y lib/getdate.y.OLD || exit 1
		cat lib/getdate.y.OLD \
			| sed 's/tm0 *= *tm;/memcpy('\\\&'tm0, '\\\&'tm, sizeof(struct tm));/' \
			| sed 's/tm *= *tm0;/memcpy('\\\&'tm, '\\\&'tm0, sizeof(struct tm));/' \
			> lib/getdate.y || exit 1

		[ -r lib/posixtm.c.OLD ] || mv lib/posixtm.c lib/posixtm.c.OLD || exit 1
		cat lib/posixtm.c.OLD \
			| sed 's/tm1 *= *tm0;/memcpy('\\\&'tm1, '\\\&'tm0, sizeof(struct tm));/' \
			> lib/posixtm.c || exit 1

		[ -r lib/strftime.c.OLD ] || mv lib/strftime.c lib/strftime.c.OLD || exit 1
		cat lib/strftime.c.OLD \
			| sed 's/ltm *= *\*tp;/memcpy('\\\&'ltm, tp, sizeof(struct tm));/' \
			> lib/strftime.c || exit 1

		[ -r lib/time_r.c.OLD ] || mv lib/time_r.c lib/time_r.c.OLD || exit 1
		cat lib/time_r.c.OLD \
			| sed 's/\*dest *= *\*src;/memcpy(dest, src, sizeof(struct tm));/' \
			> lib/time_r.c || exit 1

		[ -r lib/mktime.c.OLD ] || mv lib/mktime.c lib/mktime.c.OLD || exit 1
		cat lib/mktime.c.OLD \
			| sed 's/tm *= *\*r;/memcpy('\\\&'tm, r, sizeof(struct tm));/' \
			| sed 's/\*tp *= *tm;/memcpy(tp, '\\\&'tm, sizeof(struct tm));/' \
			> lib/mktime.c || exit 1

		[ -r lib/gettimeofday.c.OLD ] || mv lib/gettimeofday.c lib/gettimeofday.c.OLD || exit 1
		cat lib/gettimeofday.c.OLD \
			| sed 's/save *= *\*localtime_buffer_addr;/memcpy('\\\&'save, localtime_buffer_addr, sizeof(struct tm));/' \
			| sed 's/\*localtime_buffer_addr *= *save;/memcpy(localtime_buffer_addr, '\\\&'save, sizeof(struct tm));/' \
			> lib/gettimeofday.c || exit 1

	;;
	5.93-dc|5.93-th)
		[ -r lib/strftime.c.OLD ] || mv lib/strftime.c lib/strftime.c.OLD || exit 1
		cat lib/strftime.c.OLD \
			| sed 's/ltm *= *\*tp;/memcpy('\\\&'ltm, tp, sizeof(struct tm));/' \
			> lib/strftime.c || exit 1

		[ -r lib/time_r.c.OLD ] || mv lib/time_r.c lib/time_r.c.OLD || exit 1
		cat lib/time_r.c.OLD \
			| sed 's/\*dest *= *\*src;/memcpy(dest, src, sizeof(struct tm));/' \
			> lib/time_r.c || exit 1

		[ -r lib/mktime.c.OLD ] || mv lib/mktime.c lib/mktime.c.OLD || exit 1
		cat lib/mktime.c.OLD \
			| sed 's/\*tp *= *tm;/memcpy(tp, '\\\&'tm, sizeof(struct tm));/' \
			> lib/mktime.c || exit 1

		[ -r lib/gettimeofday.c.OLD ] || mv lib/gettimeofday.c lib/gettimeofday.c.OLD || exit 1
		cat lib/gettimeofday.c.OLD \
			| sed 's/save *= *\*localtime_buffer_addr;/memcpy('\\\&'save, localtime_buffer_addr, sizeof(struct tm));/' \
			| sed 's/\*localtime_buffer_addr *= *save;/memcpy(localtime_buffer_addr, '\\\&'save, sizeof(struct tm));/' \
			> lib/gettimeofday.c || exit 1

		[ -r lib/getdate.y.OLD ] || mv lib/getdate.y lib/getdate.y.OLD || exit 1
		cat lib/getdate.y.OLD \
			| sed 's/tm0 *= *tm;/memcpy('\\\&'tm0, '\\\&'tm, sizeof(struct tm));/' \
			| sed 's/tm *= *tm0;/memcpy('\\\&'tm, '\\\&'tm0, sizeof(struct tm));/' \
			> lib/getdate.y || exit 1

		[ -r lib/posixtm.c.OLD ] || mv lib/posixtm.c lib/posixtm.c.OLD || exit 1
		cat lib/posixtm.c.OLD \
			| sed 's/tm1 *= *tm0;/memcpy('\\\&'tm1, '\\\&'tm0, sizeof(struct tm));/' \
			> lib/posixtm.c || exit 1

		[ -r lib/regcomp.c.OLD ] || mv lib/regcomp.c lib/regcomp.c.OLD || exit 1
		cat lib/regcomp.c.OLD \
			| sed 's/MB_CUR_MAX/sizeof(char)/' \
			> lib/regcomp.c || exit 1
	;;
	5.9[467]-th|5.9[467]-dc)
	;;
	*)
		echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
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
	case ${PKGVER} in
	5.2.1)
		make || exit 1
	;;
	5.93)
		make seq_LDADD='-lm -L../lib -lcoreutils' \
			uptime_LDADD='-lm -L../lib -lcoreutils' \
			|| exit 1
	;;	
	5.9[467])
#		make seq_LDADD='-lm -L../lib -lcoreutils
		make \
			uptime_LDADD='-lm -L../lib -lcoreutils' \
			|| exit 1
	;;	
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

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
