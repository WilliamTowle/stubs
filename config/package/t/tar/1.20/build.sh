#!/bin/sh
# 02/07/2007

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
	1.13)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr  --bindir=/bin \
			 --host=`uname -m` --build=${TARGET_CPU} \
			 --libexecdir=/usr/bin \
			 --disable-largefile --disable-nls || exit 1

# | sed '/^INCLUDES/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
		for MF in Makefile */Makefile ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/-g //' \
				> ${MF} || exit 1
		done
	;;
	1.19|1.20)
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr  --bindir=/bin \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --libexecdir=/usr/bin \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1

		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed '/undef HAVE_SIGNED_WCHAR_T/ { s%/\* %% ; s% \*/%% }' \
			| sed '/undef HAVE_SIGNED_WINT_T/ { s%/\* %% ; s% \*/%% }' \
			| sed '/undef HAVE_WCHAR_H/ { s%/\* %% ; s% \*/%% }' \
			| sed '/undef HAVE_WCRTOMB/ { s%/\* %% ; s% \*/%% }' \
			| sed '/undef HAVE_WCTYPE_H/ { s%/\* %% ; s% \*/%% }' \
			| sed '/undef HAVE_WINT_T/ { s%/\* %% ; s% \*/%% }' \
			> config.h || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER '${PKGVER}'" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	1.13)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
			make \
			  AR=`echo ${FR_CROSS_CC} | sed 's/gcc/ar/'` \
			  || exit 1
	;;
	1.19|1.20)
		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER '${PKGVER}'" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	make prefix=${MINIMAL_INSTTEMP}/usr bindir=${MINIMAL_INSTTEMP}/bin libexecdir=${MINIMAL_INSTTEMP}/usr/bin install || exit 1

	mkdir -p ${UTILS_INSTTEMP}/usr || exit 1
	rm -rf ${UTILS_INSTTEMP}/usr/bin 2>/dev/null
	mv ${MINIMAL_INSTTEMP}/usr/bin ${UTILS_INSTTEMP}/usr/ || exit 1
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

# ...tries to use 'cc' by default. Assume cc != gcc:
	CC=${FR_HOST_CC} \
		./configure --prefix=${FR_TH_ROOT} \
		  --disable-largefile --disable-nls \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install-exec-recursive || exit 1
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
