#!/bin/sh
# 07/06/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	# necessary variables
	DISTVER=`echo ${USE_DISTRO} | sed 's/^[a-z-]*//g'`
	if [ -z "${USE_DISTRO}" ] ; then
		echo "$0: USE_DISTRO unset" 2>&1
		exit 1
	fi
	if [ -z "${INSTTEMP}" ] ; then
		echo "$0: INSTTEMP unset" 2>&1
		exit 1
	fi

# BUILD...
# INSTALL...
	mkdir -p ${TCTREE}/etc/${USE_DISTRO} || exit 1

	mkdir -p ${INSTTEMP} || exit 1
	TCTREE=${TCTREE} USE_DISTRO=${USE_DISTRO} DISTVER=${DISTVER} \
		make DESTDIR=${INSTTEMP} install || exit 1

	echo -n '' > ${INSTTEMP}/etc/motd
	echo "Franki/Earlgrey Linux - a half a pound of reasons, and a quarter pound of sense" >> ${INSTTEMP}/etc/motd
	echo "...Version ${DISTVER}, with ${PKGNAME} v${PKGVER}" >> ${INSTTEMP}/etc/motd
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
