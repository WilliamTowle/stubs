#!/bin/sh
# 2008-04-04

#TODO: newer version? random.c problem in 0.48
#TODO: newer version? Undeclared variable in 0.{48|48.1}

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -x ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
		echo "$0: Aborting - no 'fakeroot'" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
		echo "$0: Failed: No zlib.h?" 1>&2
		exit 1
	fi

	# without-included-regex here, as uClibc conflicts

	  CC=${FR_CROSS_CC} \
	    CFLAGS="-O2" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --without-included-regex \
		  || exit 1

## | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/-g / /' \
#			> ${MF} || exit 1
#	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	${FR_TH_ROOT}/usr/bin/fakeroot \
		-- make DESTDIR=${INSTTEMP} install || exit 1
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
