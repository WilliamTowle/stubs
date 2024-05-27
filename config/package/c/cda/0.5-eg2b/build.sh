#!/bin/sh
# 17/12/2005

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

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	( cd lib${PKGNAME}-${PKGVER} &&
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
		> Makefile || exit 1

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g || exit 1
		make || exit 1
	)

#		${FR_CROSS_CC} -nostdinc -I${UCPATH}/include -I${GCCINCDIR} -I${TCTREE}/usr/include -Ilib${PKGNAME}-${PKGVER} cda.c -Llib${PKGNAME}-${PKGVER} -l${PKGNAME} -o cda || exit 1
	${FR_CROSS_CC} -Ilib${PKGNAME}-${PKGVER} cda.c -Llib${PKGNAME}-${PKGVER} -l${PKGNAME} -o cda || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1/ || exit 1
	cp cda ${INSTTEMP}/usr/bin/ || exit 1
	cp cda.1 ${INSTTEMP}/usr/man/man1/ || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	exit 1
	;;
esac
