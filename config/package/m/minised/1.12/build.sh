#!/bin/sh
# 02/11/2006

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
#!`which make`

CC=${FR_CROSS_CC}

.SUFFIXES:
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
	\${CC} \${CFLAGS} -c \$*.c -o \$@

EOF
	case ${PKGVER} in
	1.4|1.5)
		cat Makefile \
			| sed 's/	cc/	${CC}/' \
			| sed 's/LFLAGS/CFLAGS/' \
			>> GNUmakefile || exit 1
	;;
	1.6)
		cat Makefile \
			| sed '/^	/ s%$(PREFIX)%$(DESTDIR)/$(PREFIX)%' \
			| sed '/^	.* minised/ s%$(PREFIX)/%%' \
			>> GNUmakefile || exit 1
		[ -r sedcomp.c.OLD ] || mv sedcomp.c sedcomp.c.OLD || exit 1
		cat sedcomp.c.OLD \
			| sed '/char \*p, \*p2/ s/p2/p2, **it/' \
			| sed '/char \*\*/ s/char \*\*//' \
			> sedcomp.c || exit 1
	;;
	1.8)
		cat Makefile \
			| sed '/^	/		s%$(PREFIX)%$(DESTDIR)/$(PREFIX)%' \
			| sed '/install minised/	s%$(PREFIX)/%%' \
			>> GNUmakefile || exit 1
	;;
	1.9|1.10|1.11|1.12)
		cat Makefile \
			| sed	' /^	/		s%$(PREFIX)%$(DESTDIR)/$(PREFIX)%
				; /^	/		s%X..man%X)/usr/man%
				; /install minised/	s%$(PREFIX)/%%
				' \
			>> GNUmakefile || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
#	make clean || exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
#		  || exit 1
	1.6|1.8|1.9|1.10|1.11|1.12)
		make || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	1.4|1.5)
		mkdir -p ${INSTTEMP}/bin || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
		if [ -x sed ] ; then
			cp sed ${INSTTEMP}/bin/ || exit 1
		elif [ -x mnsed ] ; then
			cp mnsed ${INSTTEMP}/bin/sed || exit 1
		else
			echo "$0: Confused: Neither 'sed' nor 'mnsed' built" 1>&2
			exit 1
		fi
		cp sed.1 ${INSTTEMP}/usr/man/man1/ || exit 1
	;;
	1.6|1.8|1.9|1.10|1.11|1.12)
		mkdir -p ${INSTTEMP}/bin || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
		( cd ${INSTTEMP}/bin || exit 1
			ln -sf minised sed || exit 1
		) || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
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
