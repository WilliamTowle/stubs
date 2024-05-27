#!/bin/sh
# 04/11/2006

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
	0.0.3[ab]|0.0.4)
		find ./ -name '[Mm]akefile' | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /^CC[ 	]*=/	s%g*cc%'${FR_CROSS_CC}'%
					; /^	/		s%/usr%${DESTDIR}/usr%
					; /{CC}/		s%/usr/lib/%libzeppoo/%
					' > ${MF} || exit 1
		done || exit 1

		for SF in libzeppoo/mem.c libzeppoo/kmem.c ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's/lseek64/lseek/' \
				| sed 's/off64_t/off_t/' \
				> ${SF} || exit 1
		done || exit 1
	;;
	0.0.3d)
		find ./ -name '[Mm]akefile' | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /^CC[ 	]*=/	s%g*cc%'${FR_CROSS_CC}'%
					; /^	/		s%/usr%${DESTDIR}/usr%
					' > ${MF} || exit 1
		done || exit 1
#					; /{CC}/		s%/usr/lib/%libzeppoo/%

		for SF in libzeppoo/mem.c libzeppoo/kmem.c \
			; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's/lseek64/lseek/' \
				| sed 's/off64_t/off_t/' \
				> ${SF} || exit 1
		done || exit 1

		mv symbols.c symbols.c.OLD || exit 1
		cat symbols.c.OLD \
			| sed	' /getSymbolsFingerprints/,+3 s/int i, j;//
				; /getSymbolsFingerprints/,+3 s/i = j = 0;//
				' > symbols.c || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	0.0.3a)
		( cd libzeppoo || exit 1
			make || exit 1
		) || exit 1
		make || exit 1
		#make LIBS=${ADD_LIBC_NCURSES} || exit 1
	;;
	0.0.3[bd]|0.0.4)
		( cd libzeppoo || exit 1
			make static || exit 1
		) || exit 1
		make static || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	0.0.3[abd])
		mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	0.0.4)
		mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
		cp zeppoo ${INSTTEMP}/usr/bin || exit 1
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
