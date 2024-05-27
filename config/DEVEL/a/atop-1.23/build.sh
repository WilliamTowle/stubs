#!/bin/sh
# 20/04/2006

# (22/04/2006) floating point exception since v1.15 (and 1.16)

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

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
		echo "$0: Failed: No zlib.h?" 1>&2
		exit 1
	fi

	cat >GNUmakefile <<EOF
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
	\${CROSS}cc \${CFLAGS} -c \$*.c -o \$@

EOF
## | sed '/^CFLAGS/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include -I'${FR_LIBCDIR}'/include/ncurses %' \
		cat Makefile \
			| sed "s/^		*/	/" \
			| sed 's/cc /${CROSS}cc /' \
			| sed '/^CFLAGS/ s%$% '${ADD_INCL_NCURSES}'%' \
			| sed 's/chown /-chown /' \
		 	>> GNUmakefile || exit 1
#			;;
#	*)
#		echo "$0: Unexpected DISTRO" 1>&2
#		exit 1
#		;;
#	esac \
#		|| exit 1

	if [ ${PKGVER} = '1.14' ] ; then
		[ -r acctproc.h.OLD ] || mv acctproc.h acctproc.h.OLD || exit 1
		cat acctproc.h.OLD \
			| sed 's/__u8/unsigned char/' \
			| sed 's/__u16/unsigned short/' \
			| sed 's/__u32/unsigned long/' \
			> acctproc.h || exit 1
	fi || exit 1

# no .ac_swaps/.ac_rw in 2.0 kernel...
	[ -r acctproc.c.OLD ] || mv acctproc.c acctproc.c.OLD || exit 1
	cat acctproc.c.OLD \
		| sed 's/comp_t/unsigned short/' \
		| sed 's%acctrec\.ac_swaps%0 /* acctrec.ac_swaps */%' \
		| sed 's%acctrec\.ac_rw%0 /* acctrec.ac_rw */%' \
		> acctproc.c || exit 1

	[ -r various.c.OLD ] || mv various.c various.c.OLD || exit 1
	cat various.c.OLD \
		| sed 's/5\.1lf/5.1f/' \
		> various.c || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CROSS=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  all || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/atop.d || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_tc_host || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
