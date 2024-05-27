#!/bin/sh
# 21/05/2006

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

	if [ ! -r ${FR_LIBCDIR}/include/uuid/uuid.h ] ; then
		echo "No uuid.h - no e2fsprogs built?" 1>&2
		exit 1
	fi

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2" \
	  ac_cv_header_wchar_h=no \
	  ac_cv_sys_file_offset_bits=32 \
		./configure --prefix=/usr \
		  --host=`uname -m`-`uname -s | tr 'A-Z' 'a-z'` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --without-readline \
		  || exit 1

	case ${PKGVER} in
	1.6.24|1.6.25.1)
		# no means of unrequiring wchar.h ...fudge.
		[ -r parted/strlist.h.OLD ] \
			|| mv parted/strlist.h parted/strlist.h.OLD || exit 1
		cat parted/strlist.h.OLD \
			| sed 's/#include <wchar.h>/#define wchar_t char/' \
			> parted/strlist.h || exit 1
	;;
	1.7.0rc[45]|1.7.[01])
		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed	' /ENABLE_NLS/	s%/* %%
				; /ENABLE_NLS/	s%* /%%
				' > config.h || exit 1

		[ -r parted/strlist.h.OLD ] \
			|| mv parted/strlist.h parted/strlist.h.OLD || exit 1
		cat parted/strlist.h.OLD \
			| sed 's/#include <wchar.h>/#define wchar_t char/' \
			> parted/strlist.h || exit 1

		[ -r parted/table.h.OLD ] \
			|| mv parted/table.h parted/table.h.OLD || exit 1
		cat parted/table.h.OLD \
			| sed	' /#include <wchar.h>/	s%^%/* %
				; /#include <wchar.h>/	s%$% */%
				' > parted/table.h || exit 1

		[ -r parted/ui.c.OLD ] \
			|| mv parted/ui.c parted/ui.c.OLD || exit 1
		cat parted/ui.c.OLD \
			| sed	' /	opt_script_mode/	s/^/sigset_t curr;/
				; / sigset_t curr;/	s/.*// 
				' > parted/ui.c || exit 1

		[ -r parted/table.c.OLD ] \
			|| mv parted/table.c parted/table.c.OLD || exit 1
		cat parted/table.c.OLD \
			| sed	' /assert.* ncols/	s/^/Table * t;/
				; /Table.*sizeof/	s/Table \*//
				' > parted/table.c || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...

	make || exit 1

# INSTALL...
	case ${PKGVER} in
#make prefix=${INSTTEMP}/usr install || exit 1
	1.7.1rc2|1.7.0rc[45]|1.7.[01])
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	*)	echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
