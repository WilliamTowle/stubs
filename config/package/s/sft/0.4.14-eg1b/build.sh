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
BOGUS_DC		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

#		for MF in `find ./ -name Makefile` ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/^CFLAGS/ s/-g //' \
#				| sed '/^prefix/ s%/usr%${DESTDIR}/usr%' \
#				> ${MF} || exit 1
#		done
#		;;
#	0.8.7)
#		# no more ./configure since 0.8.7
#		for MF in `find ./ -name Makefile` ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/^CC *=/ s%gcc%'${FR_CROSS_CC}'%' \
#				| sed '/^prefix/ s%/usr%${DESTDIR}/usr%' \
#				> ${MF} || exit 1
#		done
#		;;
#	*)
#		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#		;;
#	esac

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

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
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
