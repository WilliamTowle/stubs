#!/bin/sh
# 09/10/2005

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

	if [ ! -r ${FR_LIBCDIR}/include/ogg/ogg.h ] ; then
		echo "$0: Confused -- no ogg.h" 1>&2
		exit 1
	fi
	if [ ! -r ${FR_LIBCDIR}/include/ogg/ogg.h ] ; then
		echo "$0: Confused -- no ogg.h" 1>&2
		exit 1
	fi

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --with-ogg=${FR_LIBCDIR} \
		  || exit 1

	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
	cat config.h.OLD \
		| sed '/define HAVE_WCHAR_T/	s/#define/#undef/' \
		| sed '/define HAVE_WCHAR_T/	s/ 1$//' \
		| sed '/define PACKAGE_NAME/	s/""/"'${PKGNAME}'"/' \
		| sed '/define PACKAGE_STRING/	s/""/"'${PKGNAME}' '${PKGVER}${PKGREV}'"/' \
		| sed '/define PACKAGE_VERSION/	s/""/"'${PKGVER}${PKGREV}'"/' \
		> config.h || exit 1

#	find ./ -name "*[Mm]akefile" | while read MF ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CC *=/	s%g*cc%'${FR_CROSS_CC}'%' \
#			> ${MF} || exit 1
#	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	#make DESTDIR=${INSTTEMP} install || exit 1
	cp mtf ${INSTTEMP}/usr/local/bin/ || exit 1
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
