#!/bin/sh -x
# 2008-02-04

#TODO:- 1.9[12] build fails - test for 'regparm=3' bug

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

	# v >= 1.94
	if [ ! ${FR_LIBCDIR}/includelzo/lzoconf.h ] ; then
#		ADD_INCL_SDL='-I'${FR_LIBCDIR}'/usr/include/'
#		ADD_LDFLAGS_SDL='-L'${FR_LIBCDIR}'/usr/lib'
#	else
		echo "$0: Confused -- no 'lzo' (needs >= 1.02) built" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	1.9[123])
# configure cannot test for 'regparm=3' bug while cross compiling
		echo "$0: Build with own host compiler, check for 'regparm=3' bug" 1>&2
		exit 1
	;;
	1.96)
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		    CFLAGS="-O2" \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-lfs --disable-nls \
			  --without-curses \
			  --without-LZO \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac 


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
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	case ${PKGVER} in
	0.96|0.97)
		make DESTDIR=${INSTTEMP} install || exit 1
		;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#		make prefix=${INSTTEMP}/usr install || exit 1
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
