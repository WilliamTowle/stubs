#!/bin/sh
# 15/12/2005

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
	1*)

		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr --sysconfdir=/etc \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1
		;;
	2.0.1[34]*)
		# CFLAGS doesn't work
		# not sure --disable-glibtest does either

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
		done
		;;
	2.0.1[34]*)
		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
			  | sed '/_FILE_OFFSET_BITS/ s/_BITS=64/_BITS=32/' \
			  | sed '/^CFLAGS/ s/ -g / /' \
			  | sed '/^CFLAGS/ s/ -D_LARGE_FILES / /' \
			  > ${MF} || exit 1
		done
		;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g || exit 1
	make || exit 1

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
