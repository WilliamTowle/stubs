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
#		echo "$0: configure: configuration not determined" 1>&2
		if [ -d ${tctree}/cross-utils ] ; then
			fr_tc_root=${tctree}/cross-utils
			fr_th_root=${tctree}/host-utils
		else
			fr_tc_root=${tctree}/
			fr_th_root=${tctree}/
		fi

		fr_kernsrc=${fr_tc_root}/usr/src/linux-2.0.40
		fr_libcdir=${fr_tc_root}/usr/${target_cpu}-linux-uclibc
		if [ -r ${fr_th_root}/usr/bin/gcc ] ; then
			fr_host_cc=${fr_th_root}/usr/bin/gcc
		else
			fr_host_cc=`which gcc`
		fi
		fr_cross_cc=${fr_libcdir}/bin/${target_cpu}-uclibc-gcc
	fi

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

#	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#	cat config.h.OLD \
#		| sed '/define realloc/	s%^%/* %' \
#		| sed '/define realloc/	s%$% */%' \
#		> config.h || exit 1

	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC *=/	s%g*cc%'${FR_CROSS_CC}'%' \
		> Makefile || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

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
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
