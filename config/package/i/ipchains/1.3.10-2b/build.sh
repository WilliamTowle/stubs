#!/bin/sh
# 19/12/2004

#TODO: requires kernel with CONFIG_IP_FIREWALL or CONFIG_IP_FIREWALL_CHAINS set (post-2.1.102; cf /proc/net/ip_fwchains)
# TODO: normally tries to chown() - and fails

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-cross-linux-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

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
	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
		make CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	make PREFIX=${INSTTEMP} install || exit 1
}

#make_th()
#{
#}

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
