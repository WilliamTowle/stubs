#!/bin/sh -x
# 2007-12-02

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	4.14)
		for MF in Makefile libsysinfo/Makefile.defaults libsysinfo/all/Makefile po/Makefile ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC[ 	]=/	s%$%\nHOSTCC='${FR_HOST_CC}'%' \
				| sed '/^parse_logos[^:]*:/,+2 s/(CC)/(HOSTCC)/' \
				| sed 's/DESTDIR/PREFIX/g' \
				| sed '/^	.*INSTALL/	s% ..INSTALL% ${DESTDIR}/$(INSTALL%' \
				| sed 's%^	..parse_logos%	./parse_logos.host%' \
				| sed '/-o linux_logo/	s/$/ '${ADD_LDFLAGS_GETTEXT}'/' \
				> ${MF} || exit 1
		done
	;;
	5.0)
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr --bindir=/bin \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1

		for MF in Makefile Makefile.default libsysinfo-0.2.0/Makefile.default po/Makefile ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^	/ s/..CROSS.//' \
				| sed '/^CC[ 	]*=/	s%$%\nHOSTCC='${FR_HOST_CC}'%' \
				| sed '/^parse_logos[^:]*:/,+2 s/(CC)/(HOSTCC)/' \
				| sed '/^	..INSTALL/ s%..INSTALL_%${DESTDIR}/$(INSTALL_%' \
				| sed 's%^	..parse_logos%	./parse_logos.host%' \
				| sed '/-o linux_logo/	s/$/ '${ADD_LDFLAGS_GETTEXT}'/' \
				> ${MF} || exit 1
		done
	;;
	*)	echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
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

#	if [ ! -r ${FR_LIBCDIR}/lib/libasprintf.a ] ; then
#		echo "$0: CONFIGURE: No 'gettext' built" 1>&2
#		exit 1
#	else
		ADD_LDFLAGS_GETTEXT=-lintl
#	fi

	do_configure || exit 1

# BUILD...
	make parse_logos || exit 1
	cp parse_logos parse_logos.host || exit 1

	case ${PKGVER} in
	4.14)
		make clean || exit 1
		( cd libsysinfo || exit 1
			make clean || exit 1
		) || exit 1
	;;
	5.0) ;; # not special
	*)	echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	make CC=${FR_CROSS_CC} \
		|| exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/local/man/man1/ || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

#{
## CONFIGURE...
#	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
#		# Ah, sanity! 2005-11-11 onward
#		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
#	else
##		echo "$0: CONFIGURE: Configuration not determined" 1>&2
#		if [ -d ${TCTREE}/cross-utils ] ; then
#			FR_TC_ROOT=${TCTREE}/cross-utils
#			FR_TH_ROOT=${TCTREE}/host-utils
#		else
#			FR_TC_ROOT=${TCTREE}/
#			FR_TH_ROOT=${TCTREE}/
#		fi
#
#		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
#		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
#		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
#			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
#		else
#			FR_HOST_CC=`which gcc`
#		fi
#		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
#	fi
#
#	if [ ! -r ${FR_LIBCDIR}/lib/libasprintf.a ] ; then
#		echo "$0: CONFIGURE: No 'gettext' built" 1>&2
#		exit 1
#	else
#		ADD_LDFLAGS_GETTEXT=-lintl
#	fi
#
#	for MF in Makefile libsysinfo/Makefile.defaults libsysinfo/all/Makefile po/Makefile ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CC[ 	]=/	s%g*cc%'${FR_CROSS_CC}'%' \
#			| sed '/^CC[ 	]=/	s%$%\nHOSTCC='${FR_HOST_CC}'%' \
#			| sed '/^parse_logos[^:]*:/,+2 s/(CC)/(HOSTCC)/' \
#			| sed '/-o linux_logo/	s/$/ '${ADD_LDFLAGS_GETTEXT}'/' \
#			| sed 's/DESTDIR/PREFIX/g' \
#			| sed '/^	.*INSTALL/	s% ..INSTALL% ${DESTDIR}/$(INSTALL%' \
#			> ${MF} || exit 1
#	done
#
## BUILD...
#	make || exit 1
#
## INSTALL...
#	mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
#	mkdir -p ${INSTTEMP}/usr/local/man/man1/ || exit 1
#	mkdir -p ${INSTTEMP}/usr/lib/locale/ || exit 1
#	make DESTDIR=${INSTTEMP} install || exit 1
#}

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
