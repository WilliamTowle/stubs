#!/bin/sh -x
# 2008-06-19

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	if [ ! -r ${FR_LIBCDIR}/include/vga.h ] ; then
#		echo "$0: Aborting - toolchain needs 'svgalib'" 1>&2
#		exit 1
#	fi
	if [ ! -r ${FR_LIBCDIR}/include/X11/Xlib.h ] ; then
		echo "$0: Aborting - toolchain needs 'libX11' built" 1>&2
		exit 1
	fi


	[ -r ./configure ] && exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls --disable-largefile \
#		  || exit 1

# | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include -I'${FR_LIBCDIR}'/include/ncurses %' \
	cat <<EOF > GNUmakefile
#!`which make`

CC=${FR_CROSS_CC}
#CFLAGS=-nostdinc -I${FR_LIBCDIR}/include -I${GCCINCDIR} -I${TCTREE}/usr/include

.SUFFIXES:
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
	\${CC} \${CFLAGS} -c \$*.c -o \$@

EOF
	cat makefile \
		| sed '/^	/ s/gcc/${CC}/' \
		>> GNUmakefile || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
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
