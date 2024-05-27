#!/bin/sh
# 02/10/2004

#TODO:- dev.c init_device() errors - kernel version?

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

	cat <<EOF > GNUmakefile
#!gmake

.SUFFIXES:
.SUFFIXES: .c .o

CC=\${CCPREFIX}cc

.c.o: \$*.c \$*.h
	\${CC} \${CFLAGS} -c \$*.c -o \$@
EOF
	cat Makefile \
		| sed '/^#CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
		>> GNUmakefile || exit 1
echo "FIX GCCINCDIR"
	for SF in recoverdm.c utils.h ; do
		[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed '/define _LARGEFILE64_SOURCE/ s%^%/*%' \
			| sed '/define _LARGEFILE64_SOURCE/ s%$%*/%' \
			| sed 's/off64_t/off_t/g' \
			| sed 's/lseek64/lseek/g' \
			| sed 's/open64/open/g' \
			> ${SF} || exit 1
	done || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` || exit 1

# INSTALL...
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
	exit 1
	;;
esac
