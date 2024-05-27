#!/bin/sh -x
# 2008-09-06 (EARLIEST v0.3.4, 2008-01-05)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
		echo "$0: Aborting -- no 'fakeroot'" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	0.4[013])
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
	0.51)
		[ -r config.mk.OLD ] || mv config.mk config.mk.OLD || exit 1
		cat config.mk.OLD \
			| sed '/JOYSTICK[ 	*]=/	s/^/#/' \
			| sed '/XLIB[ 	*]=/		s/^/#/' \
			| sed '/UNIX[ 	*]=/		s%$%\nCC = '${FR_CROSS_CC}'\n%' \
			> config.mk || exit 1

		find ./ -name Makefile | while read MF ; do
			cat <<EOF > `dirname $MF`/GNUmakefile
#!`which make`

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
	0.4[013])
		make DESTDIR=${INSTTEMP} install
	;;
	0.51)
		${FR_TH_ROOT}/usr/bin/fakeroot \
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
