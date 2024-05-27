#!/bin/sh
# 2008-05-03 (prev 2008-01-22)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	case ${PKGVER} in
	0.3.6)
		CC=${FR_CROSS_CC} \
		  CFLAGS="-O2" \
			./configure \
			  --without-x \
			  || exit 1

		cat <<EOF > GNUmakefile
#!`which make`

CC=${FR_CROSS_CC}

.SUFFIXES:
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
		\${CC} \${CFLAGS} -c \$*.c -o \$@

EOF
		cat Makefile >> GNUmakefile || exit 1
	;;
	0.40)
		CC=${FR_CROSS_CC} \
		  CFLAGS="-O2" \
			./configure \
			  --without-joystick \
			  --without-x \
			  || exit 1

		find ./ -name Makefile | while read MF ; do
			cat <<EOF > `dirname $MF`/GNUmakefile
#!`which make`

CC=${FR_CROSS_CC}

.SUFFIXES:
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
		\${CC} \${CFLAGS} -c \$*.c -o \$@

EOF
			cat ${MF} \
				| sed 's%$(bindir)%${DESTDIR}/${bindir}%' \
				| sed 's%$(docdir)%${DESTDIR}/${docdir}%' \
				>> `dirname ${MF}`/GNUmakefile || exit 1
		done
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make || exit 1

# INSTALL...
	case ${PKGVER} in
	0.3.4|0.3.5|0.3.6)
		mkdir -p ${INSTTEMP}/usr/bin || exit 1
		cp tetris ${INSTTEMP}/usr/bin/ || exit 1
	;;
	0.40)
		make DESTDIR=${INSTTEMP} install
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
