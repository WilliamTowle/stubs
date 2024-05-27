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

	case ${PKGVER} in
	0.2.7)

		  CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=/usr --bindir=/bin \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed 's% /etc% ${DESTDIR}/etc%' \
				| sed 's% /usr% ${DESTDIR}/usr%' \
				| sed 's/ -o bin /  /' \
				| sed 's/ -g bin /  /' \
				> ${MF} || exit 1
		done
		;;
	*)	# v0.2.3?
		if [ -r ./configure ] ; then
			echo "Found ./configure"
			exit 1
		fi
# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
# | sed 's/CC=gcc/CC=${CCPREFIX}cc/' \
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC=/ s%g*cc%'${FR_CROSS_CC}'%' \
				| sed 's% /usr% ${DESTDIR}/usr%' \
				| sed 's/ -o bin /  /' \
				| sed 's/ -g bin /  /' \
				> ${MF} || exit 1
		done
		;;
	esac

# BUILD...

#		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` || exit 1
	make || exit 1

# INSTALL...
	case ${PKGVER} in
	0.2.7)
		for INSTDIR in /etc /usr/bin /usr/share/man/man8 ; do
			mkdir -p ${INSTTEMP}/${INSTDIR} || exit 1
		done
		make DESTDIR=${INSTTEMP} install || exit 1
		;;
	*)	# v0.2.3?
		for INSTDIR in /usr/bin /usr/share/man/man8 ; do
			mkdir -p ${INSTTEMP}/${INSTDIR} || exit 1
		done
		make DESTDIR=${INSTTEMP} install || exit 1
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
