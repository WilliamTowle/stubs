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

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/-g / /' \
			| sed '/^	/	s/head -1/head -n 1/' \
			> ${MF} || exit 1
	done

# | sed 's%^[^ ]*cc%${CCPREFIX}cc -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r conf-cc.OLD ] || mv conf-cc conf-cc.OLD || exit 1
	cat conf-cc.OLD \
		| sed 's%^[^ ]*cc%'${FR_CROSS_CC}'%' \
		> conf-cc || exit 1

	[ -r conf-ld.OLD ] || mv conf-ld conf-ld.OLD || exit 1
	cat conf-ld.OLD \
		| sed 's%^[^ ]*cc%'${FR_CROSS_CC}'%' \
		> conf-ld || exit 1

# BUILD...

#		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
#		  || exit 1
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
	cp memtester ${INSTTEMP}/usr/local/bin || exit 1
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

	# (05/07/2004) Willow build needs the 'included-regex'
	CC=${FR_HOST_CC} \
		./configure --prefix=${TCTREE}/usr --bindir=${TCTREE}/bin \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/-g / /' \
			| sed '/^	/	s/head -1/head -n 1/' \
			> ${MF} || exit 1
	done

	# (05/07/2004) dubious willow build re. wchar.h
	# (05/07/2004) ENABLE_NLS removal asserts --disable-nls
	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
	cat config.h.OLD \
		| sed '/define HAVE_MBRTOWC/ s/ 1//' \
		| sed '/define HAVE_MBRTOWC/ s/define/undef/' \
		| sed '/define HAVE_MBSTATE_T/ s/ 1//' \
		| sed '/define HAVE_MBSTATE_T/ s/define/undef/' \
		| sed '/define HAVE_WCHAR_H/ s/ 1//' \
		| sed '/define HAVE_WCHAR_H/ s/define/undef/' \
		| sed '/undef mbstate_t/ s/_t.*/_t char/' \
		| sed '/undef mbstate_t/ s/.*undef/#define/' \
		| sed '/define ENABLE_NLS/ s/ 1//' \
		| sed '/define ENABLE_NLS/ s/define/undef/' \
		> config.h || exit 1

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
