#!/bin/sh
# 14/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
		else
			FR_TC_ROOT=${TCTREE}/
		fi
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

# | sed '/^	/ s%cc %cc -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r Makefile.OLD ] || cp Makefile Makefile.OLD
	cat Makefile.OLD \
		| sed '/^	/ s%gcc%'${FR_CROSS_CC}'%' \
		> Makefile || exit 1

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g \
#		  `uname -s | tr 'A-Z' 'a-z'` || exit 1
	make `uname -s | tr 'A-Z' 'a-z'` || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	cp tsh tshd ${INSTTEMP}/usr/bin/ || exit 1
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
