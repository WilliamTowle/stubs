#!/bin/sh
# 26/08/2006

#TODO:- confused in hybrid compiler environment (inconsistent Makefile)?
#TODO:- wants tiffio.h

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

	if [ ! -r ${FR_LIBCDIR}/include/jpeglib.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LDFLAGS_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
		echo "$0: Confused -- no jpegsrc library" 1>&2
		exit 1
	fi


	if [ ! -r ${FR_LIBCDIR}/include/png.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LDFLAGS_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
		echo "$0: Confused -- no 'png.h' [libpng]" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/vga.h ] ; then
		echo "$0: Aborting - toolchain needs 'svgalib'" 1>&2
		exit 1
	fi

	[ -r ./configure ] && exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls --disable-largefile \
#		  || exit 1

	[ -r config.mk.OLD ] || mv config.mk config.mk.OLD || exit 1
	cat config.mk.OLD \
		| sed '/^CC=/	s%gcc%'${FR_CROSS_CC}'%' \
		> config.mk || exit 1

## | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include -I'${FR_LIBCDIR}'/include/ncurses %' \
#	for MF in `find ./ -name Makefile` ; do
#		mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^	/ s/gcc/${CCPREFIX}cc/' \
#			| sed '/^	/ s/ -g//' \
#			| sed '/^	/ s%/usr%${DESTDIR}/usr%' \
#			| sed '/^install/ s/evilbricks//' \
#			| sed '/^	chown/ s/^/#/' \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
	make -C src CC=${FR_HOST_CC} bdf2h || exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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