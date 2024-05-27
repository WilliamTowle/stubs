#!/bin/sh -x
# 2008-09-01

#NB:- hack ntreg.h to add 'hash' union name (is this right?)
#TODO:- parse error in DES stuff (openssl?)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -r chntpw-source-${PKGVER}.zip ] ; then
		unzip chntpw-source-${PKGVER}.zip
		cd chntpw-${PKGVER}
	fi

	case ${PKGVER} in
	030126)
		for MF in `find ./ -name Makefile` ; do [ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC=/ s/gcc/${CCPREFIX}cc/' \
				| sed '/^CFLAGS/ s/ -g / /' \
				| sed '/^OSSLPATH/ s%/usr%'${FR_LIBCDIR}'%' \
				> ${MF} || exit 1
		done || exit 1


		[ -r ntreg.h.OLD ] || mv ntreg.h ntreg.h.OLD || exit 1
		cat ntreg.h.OLD \
			| sed 's/  };/  } hash;/' \
			> ntreg.h || exit 1
	;;
	080526)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/^CC=/	s%g*cc%'${FR_CROSS_CC}'%' \
			> Makefile || exit 1
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

	if [ ! -d ${FR_LIBCDIR}/include/openssl ] ; then
		echo "No libssl [openssl] build" 1>&2
		exit 1
	fi || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	030126)
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			|| exit 1
	;;
	080526)
		make || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
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
