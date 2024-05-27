#!/bin/sh -x
# 09/10/2005

#TODO:- (over)use of '^gcc'?
#TODO:- Consider HAVE_FILEIO=N
#TODO:- Consider HAVE_{BMP,GIF,PNM}_SUPPORT=N
#TODO:- HOSTCC in Makefile.rules
#TODO:- NANO-X?

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/vga.h ] ; then
		echo "$0: Aborting - toolchain needs vga.h (svgalib)" 1>&2
		exit 1
	fi

#	if [ ! -x ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
#		echo "$0: Aborting - no 'fakeroot'" 1>&2
#		exit 1
#	fi

	[ -r src/Makefile.rules.OLD ] || mv src/Makefile.rules src/Makefile.rules.OLD || exit 1
	cat src/Makefile.rules.OLD \
		| sed '/\([A-Z]*INSTALLDIR\)/ s/ $(INS/ ${DESTDIR}$(INS/' \
		> src/Makefile.rules || exit 1

	[ -r src/Arch.rules.OLD ] || mv src/Arch.rules src/Arch.rules.OLD || exit 1
	cat src/Arch.rules.OLD \
		| sed 's/LINUX-NATIVE/LINUX-CUSTOM/' \
		| sed '/^COMPILER/ s/ccache//' \
		| sed '/^TOOLSPREFIX/ s%=.*%='`echo ${FR_CROSS_CC} | sed 's/gcc$//'`'%' \
		| sed '/^CFLAGS.*OPTFLAGS/	s/$/ -Dvfork=fork/' \
		> src/Arch.rules || exit 1

# (23/01/2005) | sed '/^NANOX/	s/Y/N/' \
# (23/01/2005) | sed '/^NANOXDEMO/	s/Y/N/' \
# (23/01/2005) | sed '/^NANOWM/	s/Y/N/' \
	[ -r src/config ] || mv src/config src/config.OLD || exit 1
	cat src/Configs/config.svga \
		| sed '/^VERBOSE/	s/N/Y/' \
		| sed '/^ARCH/	s/NATIVE/CUSTOM/' \
		| sed '/^GPMMOUSE[ 	]*=/	s/Y/N/' \
		| sed '/^NOMOUSE[ 	]*=/	s/N$/Y/' \
		> src/config || exit 1

	( cd src || exit 1

# BUILD...
	make || exit 1
	#( cd demos/nanowm && make ) || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	cp bin/nanowm ${INSTTEMP}/usr/bin || exit 1

	) || exit 1
	echo "FUTURE: Reinstate GPMMOUSE=Y" 1>&2
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
