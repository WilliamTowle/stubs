#!/bin/sh -x
# from INCOMING 2007-08-31

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

	if [ ! -r ${FR_LIBCDIR}/include/readline/readline.h ] ; then
		echo "$0: Confused -- no readline.h" 1>&2
		exit 1
	else
		ADD_INCL_READLINE='-I'${FR_LIBCDIR}'/readline'
	fi

	CC=${FR_CROSS_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1

	if [ -r config.h ] ; then
		echo "config.h found" 1>&2
		exit 1
#		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#		cat config.h.OLD \
#			| sed '/HAVE_WCHAR_H/	s%^/\* %%' \
#			| sed '/HAVE_WCHAR_H/	s% \*/$%%' \
#			| sed '/HAVE_WCHAR_T/	s%define%undef%' \
#			| sed '/HAVE_WCHAR_T/	s% 1%%' \
#			| sed '/HAVE_WCTYPE_H/	s%^/\* %%' \
#			| sed '/HAVE_WCTYPE_H/	s% \*/$%%' \
#			> config.h || exit 1
	fi

#	case ${PKGVER} in
#	1.23)
##	cat <<EOF > GNUmakefile
###!`which make`
##
##CC=${FR_CROSS_CC}
##
##.SUFFIXES:
##.SUFFIXES: .c .o
##
##.c.o: \$*.c \$*.h
##	\${CC} \${CFLAGS} -c \$*.c -o \$@
##
##EOF
#		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#		cat Makefile.OLD \
#			| sed '/^CC[ 	]*=/	s%g*cc%'${FR_CROSS_CC}'%' \
#			> Makefile || exit 1
#	;;
#	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#	;;
#	esac

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LIBC_NCURSES} || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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