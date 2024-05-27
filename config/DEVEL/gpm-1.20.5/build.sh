#!/bin/sh
# 2008-06-01

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -r configure.in -a ! -r configure ] ; then
		if [ ! -r ${FR_TH_ROOT}/usr/bin/autoconf ] ; then
			echo "$0: No 'autoconf' in toolchain" 1>&2
			exit 1
		fi
		${FR_TH_ROOT}/usr/bin/autoconf || exit 1
	fi

	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --disable-largefile --disable-nls \
		  || exit 1

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	/ s/ -g / /' \
			> ${MF} || exit 1
	done


	case ${PKGVER} in
	1.20.[12])
		[ -r src/gpm.c.OLD ] || mv src/gpm.c src/gpm.c.OLD || exit 1
		cat src/gpm.c.OLD \
			| sed 's/size_t len;/time_t staletime; size_t len;/' \
			> src/gpm.c || exit 1

		[ -r Makefile.include.OLD ] \
			|| mv Makefile.include Makefile.include.OLD || exit 1
		cat Makefile.include.OLD \
			| sed 's/no .*/no/' \
			> Makefile.include
	;;
	1.20.3) ;;
	1.20.4) ;;	# borked
	1.20.5)
		[ -r src/mice.c.OLD ] || mv src/mice.c src/mice.c.OLD || exit 1
		cat src/mice.c.OLD \
			| sed '/int M_imps2/,+23 {
			s/unsigned char wheel/wheel/ ;
			s/^{/{ unsigned char wheel;/
			}' \
			> src/mice.c || exit 1
	;;
	1.99.6)
		[ -r Makefile.include.OLD ] \
			|| mv Makefile.include Makefile.include.OLD || exit 1
		cat Makefile.include.OLD \
			| sed '/^CFLAGS[ 	]*/ s/ -Wextra / /' \
			> Makefile.include
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make LDFLAGS=-lm || exit 1

# INSTALL...
	make ROOT=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-cross)
#	INSTTEMP=${TCTREE} make_tc || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
