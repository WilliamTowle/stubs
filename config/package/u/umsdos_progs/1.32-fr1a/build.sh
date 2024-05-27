#!/bin/sh
# 12/01/2006

#TODO:- need to specify kernel source location?

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

# umsdos_fs04.h assumes various __kernel_* definitions need to be
# made; they are, however, *subsequently* imported by inclusion of
# certain uClibc header files. Engineer sane use of uClibc's defns:
	[ -r include/umsdos_fs04.h.OLD ] || cp include/umsdos_fs04.h include/umsdos_fs04.h.OLD
	cat > include/umsdos_fs04.h <<EOF
#include <bits/kernel_types.h>
EOF
	cat include/umsdos_fs04.h.OLD \
		| sed 's%^typedef%//typedef%' \
		>> include/umsdos_fs04.h

	[ -r include/ums_config.h.OLD ] || cp include/ums_config.h include/ums_config.h.OLD
	cat include/ums_config.h.OLD \
		| sed 's%^#define BE_UVFAT.*%#define BE_UVFAT 0%' \
		| sed 's%^#define GNU_HACK 0.*%#define GNU_HACK 1%' \
		| sed 's%^#define KERN_22X%/* #define KERN_22X */%' \
		> include/ums_config.h

# | sed '/^CFLAGS=/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
	# Note! Get "bad asm" complaints without -D_I386_STRING_H
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^GCC=/ s%gcc%${CCPREFIX}cc%' \
			| sed '/^GPP=/ s%g++%${CCPREFIX}++%' \
			| sed '/\(GCC\)/ s%(CFLAGS)%(CFLAGS) -D_I386_STRING_H_ %' \
			| sed '/^CFLAGS=/ s/ -g / /' \
			| sed '/\(GPP\)/ s/ -g / /' \
			| sed 's/-[og] bin//g' \
			| sed 's%/usr/src/linux%'${FR_KERNSRC}'%' \
			| sed 's% /usr% ${DESTDIR}/usr%g' \
			| sed 's% /sbin% ${DESTDIR}/sbin%g' \
			> ${MF} || exit 1
	done

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  all || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/sbin
	mkdir -p ${INSTTEMP}/usr/man/man8
	make DESTDIR=${INSTTEMP} install || exit 1

	# if built, check uvfat{sync,ctl,setup} too
	( cd ${INSTTEMP}/sbin &&
		for LINK in udosctl umssetup ; do
			ln -sf umssync ${LINK} || exit 1
		done
	) || exit 1
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
