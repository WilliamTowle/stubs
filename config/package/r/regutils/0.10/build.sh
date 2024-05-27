#!/bin/sh -x
# from INCOMING 2008-04-04

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -x ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
		echo "$0: Aborting - no 'fakeroot'" 1>&2
		exit 1
	fi

	if [ -r ./configure ] ; then
		echo "./configure found"
		exit 1
#	CC=${FR_CROSS_CC} \
#	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
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
	0.10)
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
			| sed '/^GROUP=/	s/wheel/root/' \
			| sed '/^CC[ 	]*=/	s/^/#/' \
			| sed '/^	/ s%$(BINDIR)%${DESTDIR}${BINDIR}%g' \
			| sed '/^	/ s%$(LIBDIR)%${DESTDIR}${LIBDIR}%g' \
			| sed '/^	/ s%$(SCRIPTBINDIR)%${DESTDIR}${SCRIPTBINDIR}%g' \
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
	${FR_TH_ROOT}/usr/bin/fakeroot \
		-- make DESTDIR=${INSTTEMP} install || exit 1
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
