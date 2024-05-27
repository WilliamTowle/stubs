#!/bin/sh
# 23/05/2005

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

# | sed '/^SYS_INCLUDES/ s%".*"%"-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include"%' \
	[ -r INSTALL.OLD ] || mv INSTALL INSTALL.OLD || exit 1
	cat INSTALL.OLD \
		| sed '/^BASE_DIR/ s%/usr.*%'`pwd`'%' \
		| sed '/^PUBLIC_BIN/ s%/usr%'${INSTTEMP}'/usr%' \
		| sed '/^INSTALL_DIR/ s%/usr%'${INSTTEMP}'/usr%' \
		| sed '/^MAN_DIR/ s%/var%'${INSTTEMP}'/var%' \
		| sed '/^TEMP_DIR/ s%/var%'${INSTTEMP}'/var%' \
		| sed '/^CC/ s%cc%'${FR_CROSS_CC}'%' \
		> INSTALL || exit 1
	chmod a+x INSTALL || exit 1

# BUILD/INSTALL...
#	mkdir -p ${INSTTEMP}/usr/local/src/${PKGNAME}-${PKGVER} || exit 1
#	mkdir -p ${INSTTEMP}/usr/local/lib/${PKGNAME}/lib || exit 1
#	mkdir -p ${INSTTEMP}/usr/local/lib/${PKGNAME}/machines || exit 1
#	mkdir -p ${INSTTEMP}/usr/local/man/man1 || exit 1
#	mkdir -p ${INSTTEMP}/usr/local/man/man5 || exit 1
	mkdir -p ${INSTTEMP}/var/tmp/ || exit 1

	./INSTALL || exit 1
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
