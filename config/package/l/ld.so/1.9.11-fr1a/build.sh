#!/bin/sh
# 29/11/2005

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

# | sed '/^CFLAGS	=/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
	[ -r Config.mk.OLD ] || cp Config.mk Config.mk.OLD
	cat Config.mk.OLD \
		| sed 's/^CC *=.*/CC=${CCPREFIX}cc/' \
		| sed 's/^LIBC5_CC *=.*/LIBC5_CC=${CCPREFIX}cc/' \
		| sed '/^CFLAGS	=/ s/-g / /' \
		> Config.mk

# BUILD...
#	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  -C util ldconfig || exit 1

# INSTALL...
#	PREFIX=${INSTTEMP} ./instldso.sh || exit 1
	mkdir -p ${INSTTEMP}/sbin || exit 1
	cp util/ldconfig ${INSTTEMP}/sbin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man8 || exit 1
	cp man/ldconfig.8 ${INSTTEMP}/usr/man/man8/ || exit 1
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