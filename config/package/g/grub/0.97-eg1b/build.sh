#!/bin/sh
# 07/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
		else
			FR_TC_ROOT=${TCTREE}/
		fi
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi


	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  CFLAGS="-O2" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-lfs --disable-nls \
		  --without-curses \
		  || exit 1

## | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#	for MF in `find ./ -name Makefile` ; do
#		mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/ -g$//' \
#			> ${MF} || exit 1
#	done

	case ${PKGVER} in
	0.95|0.96|0.97)	# ...and presumably 0.94?
		# ...need to reinforce --disable-largefile
		[ -r lib/device.c.OLD ] || cp lib/device.c lib/device.c.OLD
		cat lib/device.c.OLD \
			| sed 's/define _FILE_OFFSET_BITS.*/define _FILE_OFFSET_BITS 32/' \
			| sed 's/define _LARGEFILE_SOURCE.*/define _LARGEFILE_SOURCE 0/' \
			> lib/device.c || exit 1

		[ -r grub/asmstub.c.OLD ] || cp grub/asmstub.c grub/asmstub.c.OLD
		cat grub/asmstub.c.OLD \
			| sed 's/define _FILE_OFFSET_BITS.*/define _FILE_OFFSET_BITS 32/' \
			| sed 's/define _LARGEFILE_SOURCE.*/define _LARGEFILE_SOURCE 0/' \
			> grub/asmstub.c || exit 1
		;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	case ${PKGVER} in
	0.96|0.97)
		make DESTDIR=${INSTTEMP} install || exit 1
		;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1

#		make prefix=${INSTTEMP}/usr install || exit 1
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
