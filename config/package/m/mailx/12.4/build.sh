# 13/01/2007

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

	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
		echo "No libssl [openssl] build" 1>&2
		exit 1
	fi

	# ./configure ditched as of v10.8
	CC=${FR_HOST_CC} \
		sh makeconfig || exit 1

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^#*CFLAGS/ s/^#*//' \
			| sed '/^UCBINSTALL/ s%=.*%='${FR_TH_ROOT}'/bin/install%' \
			> ${MF} || exit 1
	done

	mv config.h config.h.OLD || exit 1
	cat config.h.OLD \
		| sed '/define HAVE_ICONV/ s/define/undef/' \
		| sed '/define HAVE_MREMAP/ s/define/undef/' \
		| sed '/define HAVE_SETLOCALE/ s/define/undef/' \
		| sed '/define HAVE_WCTYPE_H/ s/define/undef/' \
		| sed '/define HAVE_WCWIDTH/ s/define/undef/' \
		| sed '/define HAVE_WORDEXP/ s/define/undef/' \
		> config.h || exit 1

# BUILD...
	make CC=${FR_CROSS_CC} \
	  all || exit 1

# INSTALL...
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