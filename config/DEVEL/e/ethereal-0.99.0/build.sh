#!/bin/sh -x
# 2007-11-25

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

	if [ ! -r ${FR_LIBCDIR}/lib/libiconv.a ] ; then
		echo "$0: Confused -- libiconv.a not found" 1>&2
		exit 1
	else
		ADD_LIBS_ICONV='-L'${FR_LIBCDIR}
	fi

	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
		exit 1
	fi

#	PATH=${FR_LIBCDIR}/bin:${PATH}
#		  --disable-glibtest
#		  --disable-gtktest
#		  --disable-gtk2
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --bindir=/bin \
		  --libexecdir=/usr/bin \
		  --build=`uname -m` --host=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --disable-usr-local \
		  --disable-ethereal \
		  --without-gtk \
		  || exit 1

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/	s/ -g / /' \
			| sed '/^all:/	s/config.h//' \
			> ${MF} || exit 1
	done

	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
	cat config.h.OLD \
		| sed '/^HAVE_LIBGNUTLS/	 { s/define/undef/ ; s/ 1$// }' \
		> config.h || exit 1

# BUILD...
	case ${PKGVER} in
#	0.10.14)
#		make CC=${FR_HOST_CC} rdps || exit 1
#		make CC=${FR_HOST_CC} -C tools/lemon lemon || exit 1
#		make all || exit 1
#	;;
	0.99.0)
		make CC=${FR_HOST_CC} rdps || exit 1
		make CC=${FR_HOST_CC} -C tools/lemon lemon || exit 1
		make tethereal || exit 1
echo "..." ; exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
