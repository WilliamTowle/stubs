#!/bin/sh
# 07/12/2005

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

	[ -r Configure.OLD ] || mv Configure Configure.OLD || exit 1
	cat Configure.OLD \
		| sed "s%'./try'%'test -r ./try'%" \
		> Configure || exit 1

	# Can't use cross compiler if executables won't run natively

# CFLAGS='-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include' \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  || exit 1

	for SF in config.h di.c di.h dilib.c ; do
		[ -r ${SF}.OLD ] || mv $SF ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed '/^#define SIZ_LONG_LONG/ s%/\*%%' \
			| sed '/^#define SIZ_LONG_LONG/ s%^%/* %' \
			| sed 's/_(/_ARGS(/' \
			| sed '/define _enable_nls/ s%1%0 /* 1 */%' \
			> ${SF} || exit 1
	done

	mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC / s/=.*/= ${CCPREFIX}cc/' \
		| sed 's%-[IL]/usr/local/include%%' \
		| sed 's%= /usr%= ${DESTDIR}/usr%' \
		| sed '/^MANDIR/ s%local/%%' \
		| sed '/^MANDIR/ s%share/%%' \
		> Makefile || exit 1

# BUILD...

		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_tc || exit 1
#	;;
*)
	exit 1
	;;
esac
