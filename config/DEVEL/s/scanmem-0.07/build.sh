#!/bin/sh
# 07/04/2007

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

#	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

	if [ ! -r ${FR_LIBCDIR}/include/readline/readline.h ] ; then
		echo "$0: Confused -- no readline.h" 1>&2
		exit 1
#	else
#		ADD_INCL_READLINE='-I'${FR_LIBCDIR}'/readline'
	fi

	if [ "${PKGVER}" = 0.03 ] ; then
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC[ 	]*=/	s%g*cc%'${FR_CROSS_CC}'%' \
			> Makefile || exit 1
	else
		CC=${FR_CROSS_CC} \
		  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
		  ac_cv_lib_readline_readline=yes \
		  ac_cv_file__proc_self_maps=yes \
		  ac_cv_file__proc_self_mem=yes \
		  ac_cv_sys_file_offset_bits=32 \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls \
			  || exit 1

		case ${PKGVER} in
		0.07)
			[ -r ptrace.c.OLD ] || mv ptrace.c ptrace.c.OLD
			cat ptrace.c.OLD \
				| sed '/define _FILE_OFFSET_BITS/ { s%^%/* % ; s%$% */% }' \
				> ptrace.c || exit 1
		;;
		esac
#		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#		cat config.h.OLD \
#			| sed '/undef _FILE_OFFSET_BITS/ { s%/\* %% ; s% \*/%% }' \
#			> config.h || exit 1
	fi

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LIBC_NCURSES} || exit 1

# INSTALL...
	case ${PKGVER} in
	0.03|0.05)
		mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
		cp scanmem ${INSTTEMP}/usr/local/bin || exit 1
	;;
	0.06)
		mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
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
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
