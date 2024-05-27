#!/bin/sh
# 2008-04-11

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -r ./configure ] ; then
		echo "$0: CONFIGURE: Unexpected ./configure" 1>&2
		exit 1
	fi

	if [ -r ./config.h ] ; then
		echo "$0: CONFIGURE: Unexpected ./config.h" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	3.28)
		find ./ -name "*[Mm]akefile" | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC *=/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^	/ s/DESTIDIR/DESTDIR/' \
				| sed '/	install/ s/-o [^)]*[)]//' \
				| sed '/	install/ s/-g [^)]*[)]//' \
				> ${MF} || exit 1
		done
	;;
	3.31|3.32)
		find ./ -name "*[Mm]akefile" | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC *=/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^	/ s/DESTIDIR/DESTDIR/' \
				| sed '/	/ s/ -o \$(ROOT) / /' \
				| sed '/	/ s/ -g \$(ROOT) / /' \
				> ${MF} || exit 1
		done
	;;
	3.34|3.35|3.42)
		find ./ -name "*[Mm]akefile" | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC *=/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/	/ s/ -o \$(ROOT) / /' \
				| sed '/	/ s/ -g \$(ROOT) / /' \
				> ${MF} || exit 1
		done
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	3.34|3.35|3.42)
#		PATH=${FR_LIBCDIR}/bin:${PATH} \
#			make || exit 1
		make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	3.34|3.35|3.42)
		mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
		mkdir -p ${INSTTEMP}/usr/sbin || exit 1
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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
