#!/bin/sh
# 30/11/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	case ${PKGVER} in
	0.5)	# and earlier? Possibly buggy
		[ -r install-lpr.OLD ] || mv install-lpr install-lpr.OLD || exit 1
		cat install-lpr.OLD \
			| sed 's%/usr%${DESTDIR}/usr%g' \
			| sed '/\/fi/ s/$/ || exit 1/' \
			| sed '/\/install / s/$/ || exit 1/' \
			| sed '/\/mv / s/$/ || exit 1/' \
			> install-lpr || exit 1
		;;
	0.6)
		[ -r install-lpr.OLD ] || mv install-lpr install-lpr.OLD || exit 1
		cat install-lpr.OLD \
			| sed 's%/usr%${DESTDIR}/usr%g' \
			| sed '/\/fi/ s/$/ || exit 1/' \
			| sed '/\/install / s/$/ || exit 1/' \
			| sed '/\/mv / s/$/ || exit 1/' \
			> install-lpr || exit 1
	;;
	0.9|0.9a)
		[ -r install.OLD ] || mv install install.OLD || exit 1
			# language-specific nastiness in man page installation
		cat install.OLD \
			| sed 's/bash/bash/' \
			| sed 's%/etc%${DESTDIR}/etc%g' \
			| sed 's%/usr%${DESTDIR}/usr%g' \
			| sed 's%share/%%' \
			| sed '/^cp/	s/$/ || exit 1/' \
			| sed '/^ ln/	s/$/ || exit 1/' \
			| sed '/^cp -i/	s/-i//' \
			| sed '/^man5$/ s/en/de/' \
			| sed '/de[_\/]/ s/^/#/' \
			> install || exit 1
	;;
	*)	echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# BUILD...
	case ${PKGVER} in
	0.5|0.6)	# and earlier? Possibly buggy
		chmod a+x install-lpr || exit 1
	;;
	0.9|0.9a)
		chmod a+x install || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	0.5|0.6)	# and earlier? Possibly buggy
		DESTDIR=${INSTTEMP} ./install-lpr || exit 1
	;;
	0.9|0.9a)
		mkdir -p ${INSTTEMP}/etc || exit 1
		mkdir -p ${INSTTEMP}/usr/bin || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
		mkdir -p ${INSTTEMP}/usr/man/man5 || exit 1
		DESTDIR=${INSTTEMP} ./install || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
	;;
	esac
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
