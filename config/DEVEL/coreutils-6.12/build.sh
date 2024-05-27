#!/bin/sh
# 2008-04-22 (prev 2006-10-29)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	6.11)
	  ac_cv_func_getloadavg=no \
	  CC=${FR_CROSS_CC} \
	  CFLAGS=-O2 \
		./configure --prefix=/ \
		  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
		  --disable-largefile --disable-nls \
		  --disable-rpath --disable-dependency-tracking \
		  --without-included-regex \
		  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	case ${PHASE}-${FR_TARGET_DEFN} in
	dc*uclibc*)
		# v6.10: No 'gnulib' subdir
		[ -r lib/freadahead.c.OLD ] || mv lib/freadahead.c lib/freadahead.c.OLD
		cat lib/freadahead.c.OLD \
			| sed '/__STDIO_BUFFERS/ s%__%/* not 0.9.20 __*/%' \
			> lib/freadahead.c || exit 1

		for SF in fseterr.c freading.c fseeko.c ; do
			[ -r lib/${SF}.OLD ] || mv lib/${SF} lib/${SF}.OLD || exit 1
			cat lib/${SF}.OLD \
				| sed 's/__modeflags/modeflags/' \
				| sed 's/__bufpos/bufpos/' \
				| sed 's/__bufread/bufread/' \
				| sed 's/__bufstart/bufstart/' \
				> lib/${SF} || exit 1
		done
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
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CC=${FR_CROSS_CC} seq_LDADD="-lm -L../lib -lfetish"  || exit 1

# INSTALL...
	#make prefix=${INSTTEMP}/usr install || exit 1
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
	  ac_list_mounted_fs=no \
	  gl_cv_list_mounted_fs=no \
		./configure --prefix=${FR_TH_ROOT} \
		  CFLAGS='-O2' \
		  || exit 1

	case ${PKGVER} in
	5.0.91)
		chmod a+x config/install-sh || exit 1 ;;
	esac
	case ${PKGVER} in
	5.0|5.0.91)	# for on Willow:
		if [ -r /lib/ld-linux.so.1 ] ; then
			[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
			cat config.h.OLD \
				| sed '/define HAVE_MBRTOWC/ s/ 1//' \
				| sed '/define HAVE_MBRTOWC/ s/define/undef/' \
				| sed '/define HAVE_WCHAR_H/ s/ 1//' \
				| sed '/define HAVE_WCHAR_H/ s/define/undef/' \
				| sed '/define HAVE_WCTYPE_H/ s/ 1//' \
				| sed '/define HAVE_WCTYPE_H/ s/define/undef/' \
				> config.h || exit 1
		fi
	;;
	5.2.1)
		if [ -r /lib/ld-linux.so.1 ] ; then
			[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
			cat config.h.OLD \
				| sed '/define HAVE_MBRTOWC/ s/ 1//' \
				| sed '/define HAVE_MBRTOWC/ s/define/undef/' \
				| sed '/undef mbstate_t/ s/_t.*/_t char/' \
				| sed '/undef mbstate_t/ s/.*undef/#define/' \
				| sed '/define HAVE_MBSTATE_T/ s/ 1//' \
				| sed '/define HAVE_MBSTATE_T/ s/define/undef/' \
				| sed '/define HAVE_WCHAR_H/ s/ 1//' \
				| sed '/define HAVE_WCHAR_H/ s/define/undef/' \
				| sed '/define HAVE_WCTYPE_H/ s/ 1//' \
				| sed '/define HAVE_WCTYPE_H/ s/define/undef/' \
				> config.h || exit 1
		fi
	;;
	esac

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
