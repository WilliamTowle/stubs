#!/bin/sh
# 2008-04-04

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
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-lfs --disable-nls \
			  || exit 1

		case ${PKGVER} in
		1.37|1.38|1.40.[268])
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
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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
