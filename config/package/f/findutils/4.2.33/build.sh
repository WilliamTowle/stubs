#!/bin/sh -x
# 2008-03-02
# *** versions 4.2.26 onward ***

#TODO:- need to specify kernel source location?
#TODO:- v4.3.5 claims "wchar.h:47: empty file name in `#include'" (mbchar.o)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PHASE} in
	dc)
		# without-included-regex here, as uClibc conflicts
		# PATH needs autoconf >= 2.58
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
	;;
	th)
		  CC=${FR_HOST_CC} \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  --host=`uname -m` --build=`uname -m` \
			  --disable-largefile --disable-nls \
			  || exit 1
	;;
	*)
		echo "$0: Unexpected PHASE '$PHASE'" 1>&2
		exit 1
	;;
	esac

	case ${PHASE}-${FR_TARGET_DEFN} in
	dc*uclibc*|dc*earlgrey*)
		[ -r gnulib/lib/freadahead.c.OLD ] || mv gnulib/lib/freadahead.c gnulib/lib/freadahead.c.OLD
		cat gnulib/lib/freadahead.c.OLD \
			| sed '/__STDIO_BUFFERS/ s%__%/* not 0.9.20 __*/%' \
			> gnulib/lib/freadahead.c || exit 1
		[ -r gnulib/lib/freading.c.OLD ] || mv gnulib/lib/freading.c gnulib/lib/freading.c.OLD
		cat gnulib/lib/freading.c.OLD \
			| sed '/__FLAG_READING/ s/__modeflags/modeflags/' \
			> gnulib/lib/freading.c || exit 1
		[ -r gnulib/lib/fseeko.c.OLD ] || mv gnulib/lib/fseeko.c gnulib/lib/fseeko.c.OLD
		cat gnulib/lib/fseeko.c.OLD \
			| sed 's/__modeflags/modeflags/' \
			| sed 's/__bufpos/bufpos/' \
			| sed 's/__bufread/bufread/' \
			| sed 's/__bufstart/bufstart/' \
			> gnulib/lib/fseeko.c || exit 1
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

#	case ${PKGVER} in
#	#? 4.2.29)
#	#	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#	#	cat config.h.OLD \
#	#		| sed '/undef HAVE_WCHAR_H/	s/^.. //' \
#	#		| sed '/undef HAVE_WCHAR_H/	s/ ..$//' \
#	#		| sed '/undef HAVE_WTYPE_H/	s/^.. //' \
#	#		| sed '/undef HAVE_WTYPE_H/	s/ ..$//' \
#	#		> config.h || exit 1
#	4.3.5)
#		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#		cat config.h.OLD \
#			| sed '/undef HAVE_WCHAR_H/	{ s/^.. // ; s/ ..$// }' \
#			| sed '/define HAVE_WCHAR_T/	{ s/define/undef/ ; s/ 1// }' \
#			| sed '/undef HAVE_WCTYPE_H/	{ s/^.. // ; s/ ..$// }' \
#			> config.h || exit 1
#	;;
#	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#	;;
#	esac

# BUILD...
	make all || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	if [ ! -r ${INSTTEMP}/usr/bin/find ] ; then
		echo "$0: Confused - where's 'find'??" 1>&2
		exit 1
	fi
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
	make all || exit 1

# INSTALL...
	make DESTDIR='' install || exit 1
	if [ ! -r ${FR_TH_ROOT}/usr/bin/find ] ; then
		echo "$0: Confused - where's 'find'??" 1>&2
		exit 1
	fi
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
