#!/bin/sh
# 14/02/2007

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

#	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
#		echo "No libssl build" 1>&2
#		exit 1
#	fi

	if [ -r ./configure ] ; then
		echo "./configure found"
		exit 1
#	CC=${FR_CROSS_CC} \
#	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls \
#		  --with-included-regex \
#		  || exit 1
	fi

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

	case ${PKGVER} in
	0.0.3)
	cat <<EOF > GNUmakefile
#!`which make`

CC=${FR_CROSS_CC}

.SUFFIXES:
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
	\${CC} \${CFLAGS} -c \$*.c -o \$@

EOF
		#[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile \
			| sed '/^	/	s/g*cc/$(CC)/' \
			>> GNUmakefile || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
