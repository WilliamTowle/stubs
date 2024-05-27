#!/bin/sh
# 02/10/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi
# GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	case ${PKGVER} in
	1*)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr --sysconfdir=/etc \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1
		;;
	2.0.11)
		# CFLAGS doesn't work
		# not sure --disable-glibtest does either
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr --sysconfdir=/etc \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --disable-glibtest \
			  || exit 1

		[ -r src/config.h.OLD ] || mv src/config.h src/config.h.OLD || exit 1
		cat src/config.h.OLD \
			| sed '/glib.h/	s/.*/typedef enum { FALSE, TRUE } gboolean;/' \
			> src/config.h || exit 1
		;;
	2*)
		# CFLAGS doesn't work
		# not sure --disable-glibtest does either
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr --sysconfdir=/etc \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --disable-glibtest \
			  || exit 1
		;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	case ${PKGVER} in
	1*)
		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/_FILE_OFFSET_BITS/ s/_BITS=64/_BITS=32/' \
				| sed '/^prefix/	s%= */%= ${DESTDIR}/%' \
				| sed '/^[a-z]*dir/	s%= */%= ${DESTDIR}/%' \
				> ${MF} || exit 1
		done || exit 1
		;;
	2*)
		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
			  | sed '/_FILE_OFFSET_BITS/ s/_BITS=64/_BITS=32/' \
			  | sed '/^CFLAGS/ s/ -g / /' \
			  | sed '/^CFLAGS/ s/ -D_LARGE_FILES / /' \
			  | sed '/^prefix/	s%= */%= ${DESTDIR}/%' \
			  | sed '/^[a-z]*dir/	s%= */%= ${DESTDIR}/%' \
			  > ${MF} || exit 1
		done || exit 1
		;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac \
		|| exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/sbin/ || exit 1
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
