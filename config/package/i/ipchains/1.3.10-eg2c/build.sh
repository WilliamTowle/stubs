#!/bin/sh
# 07/12/2005

#TODO: requires kernel with CONFIG_IP_FIREWALL or CONFIG_IP_FIREWALL_CHAINS set (post-2.1.102; cf /proc/net/ip_fwchains)
# TODO: normally tries to chown() - and fails

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

# ...v1.3.10 can extract from source in prebuilt state, so 'make clean'
	make clean || exit 1
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
# ...install will fail as ordinary user unless we chown elsewhere
# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	cat Makefile.OLD \
		| sed '/^COPTS/ s/ -g //' \
		| sed 's/-o root/${UIDOPTS}/' \
		| sed 's/-g root/${GIDOPTS}/' \
		> Makefile || exit 1

# BUILD...

		make CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	make PREFIX=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
