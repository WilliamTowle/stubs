#!/bin/sh
# 13/07/2006

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

	case ${PKGVER} in
	1.3)
		cat > Makefile <<EOF
#!`which make`
CC=\${CCPREFIX}cc
# | sed 's%(CC)%(CC) -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %'
EOF
		cat Makefile.linux \
			| sed 's%/usr/local%${DESTDIR}/usr/local%' \
			>> Makefile || exit 1
	;;
	1.4)
		CC=${FR_CROSS_CC} \
		  ac_cv_func_malloc_nonnull=yes \
		  CFLAGS="-O2" \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls \
			  --with-ssh=/usr/bin/ssh \
			  || exit 1

		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed	' /define HAVE_MALLOC/	s%0%1 /* 0 */%
				; /define malloc/	s%^%/* %
				; /define malloc/	s%$% */%
				; /define realloc/	s%^%/* %
				; /define realloc/	s%$% */%
				' > config.h || exit 1

		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed	' s/{prefix}/{PREFIX}/
				; s/{exec_prefix}/{PREFIX}/
				; s/(BINDIR)/{DESTDIR}${BINDIR}/
				; s/(DATADIR)/{DESTDIR}${DATADIR}/
				; s/(MANDIR)/{DESTDIR}${MANDIR}/
				; s/(PREFIX)/{DESTDIR}${PREFIX}/
				' > Makefile || exit 1
	;;
	1.4a)
		CC=${FR_CROSS_CC} \
		  ac_cv_func_malloc_nonnull=yes \
		  ac_cv_path_ssh=/usr/bin/ssh \
		  CFLAGS="-O2" \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls \
			  || exit 1

		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed	' /define HAVE_MALLOC/	s%0%1 /* 0 */%
				; /define malloc/	s%^%/* %
				; /define malloc/	s%$% */%
				; /define realloc/	s%^%/* %
				; /define realloc/	s%$% */%
				' > config.h || exit 1

		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed	' s%(bindir)%{DESTDIR}/${bindir}%
				; s%(datadir)%{DESTDIR}/${datadir}%
				; s%(mandir)%{DESTDIR}/${mandir}%
				; s%(prefix)/share%{DESTDIR}/${datadir}%
				' > Makefile || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	1.3)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make CC=${FR_CROSS_CC} || exit 1
	;;
	1.4)
		make || exit 1
	;;
	1.4a)
		make || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	1.3)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	1.4|1.4a)
		mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
