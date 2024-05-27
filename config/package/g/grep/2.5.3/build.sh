#!/bin/sh -x
# 2008-06-22

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			patch --batch -d ${PKGNAME}-${PKGVER} -Np1 < ${PF} || exit 1
		done

		cd ${PKGNAME}-${PKGVER}
	fi

## ...first, fix the test for whether slash works in filenames (ie.
## unix versus DOS box): verbatim, it assumes /bin/sh is bash - not
## necessarily true.
#	[ -r configure.OLD ] || mv configure configure.OLD || exit 1
#	SQ="'"
#	sed 's%".\\."%'${SQ}'.\\.'${SQ}'%' configure.OLD \
#		> configure || exit 1
#	chmod a+x configure

	case ${PHASE} in
	dc)
## ...CPPFLAGS setting as suggested for glibc=2.1.x:
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
		CC=${FR_CROSS_CC} \
		  CFLAGS=-O2 \
		  CPPFLAGS="-Dre_max_failures=re_max_failures2" \
			./configure --prefix=/usr --bindir=/bin \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  --disable-largefile --disable-nls \
			  --disable-perl-regexp \
			  || exit 1
	;;
	th)
		CC=${FR_HOST_CC} \
		  CFLAGS='-O2' \
		  CPPFLAGS="-Dre_max_failures=re_max_failures2" \
			./configure --prefix=${FR_TH_ROOT}/usr \
			  --bindir=${FR_TH_ROOT}/bin \
			  --disable-nls \
			  --disable-perl-regexp \
			  || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/lib/libintl.a ] ; then
		echo "$0: CONFIGURE: No 'gettext-intl' built" 1>&2
		exit 1
	else
		ADD_LDFLAGS_INTL='-lintl'
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
	make LDFLAGS=${ADD_LDFLAGS_INTL} || exit 1
	
# INSTALL...
	make prefix=${INSTTEMP}/usr bindir=${INSTTEMP}/bin install || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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
