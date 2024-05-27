#!/bin/sh
# 07/02/2007

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
	0.59*)
# | sed 's/ CC=gcc / CC=${CROSS}gcc /' \
# | sed "/CFLAGS='/ s%'%' -nostdinc -I"${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed 's/$(PREFIX)/$(DESTDIR)$(PREFIX)/' \
				| sed 's% CC=gcc % CC='${FR_CROSS_CC}' %' \
				| sed 's/-m486//' \
				| sed 's/-DPENTIUM_OPT//' \
				| sed '/o \\/ N ; s/\\\n[   ]*/ /' \
				> ${MF} || exit 1
		done
	;;
	0.6[35])
		CC=${FR_CROSS_CC} \
		  CFLAGS="-O2 ${ADD_INCL_NCURSES} ${ADD_INCL_SDL} -DNOXFERMEM" \
		  LDFLAGS="${ADD_LDFLAGS_SDL}" \
		  ac_cv_func_setpriority=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls \
			  --with-included-regex \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	0.59*)
		make `uname -s | tr A-Z a-z` || exit 1
	;;
	0.6[35])
		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
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
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
