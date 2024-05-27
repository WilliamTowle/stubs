#!/bin/sh
# 24/01/2005

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

	if [ ! -r ${FR_LIBCDIR}/include/vga.h ] ; then
		echo "$0: Aborting - toolchain needs 'svgalib'" 1>&2
		exit 1
	fi

#	if [ ! -x ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
#		echo "$0: Aborting - no 'fakeroot'" 1>&2
#		exit 1
#	fi

	[ -r ./configure ] && exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls --disable-largefile \
#		  || exit 1

	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/	s/gcc/$(CCPREFIX)cc/' \
			| sed '/^	/ s%$(BINDIR)%${DESTDIR}/${BINDIR}%g' \
			| sed '/^	/ s%$(MANDIR)%${DESTDIR}/${MANDIR}%g' \
			> ${MF} || exit 1
	done || exit 1

# BUILD...
	make CC=${FR_HOST_CC} bdf2h || exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/local/man/man1 || exit 1
#	${FR_TH_ROOT}/usr/bin/fakeroot \
#		-- make DESTDIR=${INSTTEMP} install || exit 1
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
