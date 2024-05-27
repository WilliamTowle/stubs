#!/bin/sh
# 25/06/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PHASE} in
	dc)
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		    CFLAGS="-O2" \
			./configure --prefix= \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-lfs --disable-nls \
			  || exit 1

		case ${PKGVER} in
#	1.35|1.37|1.38)
		1.38|1.40.2)
			[ -r misc/filefrag.c.OLD ] \
				|| mv misc/filefrag.c misc/filefrag.c.OLD || exit 1
			cat misc/filefrag.c.OLD \
				| sed '/_LARGEFILE64_SOURCE/	s/define/undef/' \
				| sed 's%O_LARGEFILE%0 /* O_LARGEFILE */%' \
				| sed 's/stat64/stat/' \
				> misc/filefrag.c || exit 1
		;;
		*)
			echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
			exit 1
		;;
		esac
	;;
	tc)
		  CC=${FR_CROSS_CC} \
		    CFLAGS="-O2" \
			./configure --prefix=${FR_LIBCDIR} \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-lfs --disable-nls \
			  || exit 1
	;;
	*)
		echo "$0: do_configure(): Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac
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
	make -C util CC=${FR_HOST_CC} subst || exit 1
	make all || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/etc
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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

	PHASE=tc do_configure || exit 1

# BUILD...
	make libs || exit 1

# INSTALL...
	make DESTDIR='' install-libs || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
