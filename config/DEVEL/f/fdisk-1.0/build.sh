#!/bin/sh -x
# 13/07/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
#	CC=${FR_CROSS_CC}
	CC=${FR_CROSS_CC} \
	HOSTCC=${FR_HOST_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1
#		  --host=`uname -m`-linux-gnu --build=${TARGET_CPU}-linux-uclibc \

	# see 'parted' dc-build for other potential change code:

#	# 16/06/2007: fdisk.c variable declarations
#	[ -r src/fdisk.c.OLD ] || mv src/fdisk.c src/fdisk.c.OLD || exit 1
#	cat src/fdisk.c.OLD \
#		| sed '/PedSector total_drive_size/	s/PedSector //' \
#		| sed '/sects_nbytes;/		s/$/\n	PedSector total_drive_size;/' \
#		| sed '/unsigned int i/		s/unsigned int //' \
#		| sed '/total_drive_size;/	s/$/\n	unsigned int i;/' \
#		| sed '/PedSector total_cyl/	s/PedSector //' \
#		| sed '/total_drive_size;/	s/$/\n	PedSector total_cyl;/' \
#		| sed '/int type_size/		s/int //' \
#		| sed '/total_drive_size;/	s/$/\n	int type_size;/' \
#		| sed '/unsigned int part_type/	s/unsigned int //' \
#		| sed '/total_drive_size;/	s/$/\n	unsigned int part_type;/' \
#		| sed '/	char \*type_name/	s/char //' \
#		| sed '/total_drive_size;/	s/$/\n	char *type_name;/' \
#		> src/fdisk.c || exit 1

	[ -r src/strlist.h.OLD ] \
		|| mv src/strlist.h src/strlist.h.OLD || exit 1
	cat src/strlist.h.OLD \
		| sed 's/#include <wchar.h>/#define wchar_t char/' \
		> src/strlist.h || exit 1
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

#	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

	if [ ! -r ${FR_LIBCDIR}/include/parted/parted.h ] ; then
		echo "No (lib)parted built" 1>&2
		exit 1
	fi

	do_configure || exit 1

#	if [ -r config.h ] ; then
#		echo "config.h found" 1>&2
#		exit 1
##		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
##		cat config.h.OLD \
##			| sed '/HAVE_WCHAR_H/	s%^/\* %%' \
##			| sed '/HAVE_WCHAR_H/	s% \*/$%%' \
##			| sed '/HAVE_WCHAR_T/	s%define%undef%' \
##			| sed '/HAVE_WCHAR_T/	s% 1%%' \
##			| sed '/HAVE_WCTYPE_H/	s%^/\* %%' \
##			| sed '/HAVE_WCTYPE_H/	s% \*/$%%' \
##			> config.h || exit 1
#	fi

#	case ${PKGVER} in
#	0.9)
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
#
#echo "..." ; exit 1

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
