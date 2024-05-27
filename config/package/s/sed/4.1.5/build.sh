#!/bin/sh -x
# 29/11/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER}-${PHASE} in
	4.1.5-dc)
		# without-included-regex here, as uClibc conflicts
		# (30/01/2005) wants a sane 'grep' PATHed
#		PATH=${TCTREE}/bin:${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr --bindir=/bin \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
### | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
##	for MF in `find ./ -name Makefile` ; do
##		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
##		cat ${MF}.OLD \
##			| sed '/^CFLAGS/ s/-g / /' \
##			> ${MF} || exit 1
##	done
	;;
	4.1.5-th)
#		PATH=${TCTREE}/bin:${PATH}
		  CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=${FR_TH_ROOT} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

#	# (05/07/2004) dubious willow build re. wchar.h
#	# (05/07/2004) ENABLE_NLS removal asserts --disable-nls
#	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#	cat config.h.OLD \
#		| sed '/define HAVE_MBRTOWC/ s/ 1//' \
#		| sed '/define HAVE_MBRTOWC/ s/define/undef/' \
#		| sed '/define HAVE_MBSTATE_T/ s/ 1//' \
#		| sed '/define HAVE_MBSTATE_T/ s/define/undef/' \
#		| sed '/define HAVE_WCHAR_H/ s/ 1//' \
#		| sed '/define HAVE_WCHAR_H/ s/define/undef/' \
#		| sed '/undef mbstate_t/ s/_t.*/_t char/' \
#		| sed '/undef mbstate_t/ s/.*undef/#define/' \
#		| sed '/define ENABLE_NLS/ s/ 1//' \
#		| sed '/define ENABLE_NLS/ s/define/undef/' \
#		> config.h || exit 1
}

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

	PHASE=dc do_configure || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make \
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc/ar/'` \
		  RANLIB=`echo ${FR_CROSS_CC} | sed 's/gcc/ranlib/'` \
		  || exit 1

# INSTALL...
	# odd need to compile more stuff
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	PHASE=th do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
