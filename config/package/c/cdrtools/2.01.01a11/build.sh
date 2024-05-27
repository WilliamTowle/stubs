#!/bin/sh
# 15/06/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#cat <EOF
##TODO:- gets dependency generation wrong wrt kernel location! FIXME!!
#EOF
# CONFIGURE...
	[ -r DEFAULTS/Defaults.linux.OLD ] || mv DEFAULTS/Defaults.linux DEFAULTS/Defaults.linux.OLD
	cat DEFAULTS/Defaults.linux.OLD \
		| sed '/DEFCCOM/ { s/^/#/ ; s%gcc$%'${FR_CROSS_CC}'% ; /gcc/ s/^#// }' \
		| sed '/^INS_BASE=/	s%/.*%/usr%' \
		| sed '/^INS_KBASE=/	s%/.*%/usr%' \
		> DEFAULTS/Defaults.linux
	( cd RULES && ln -sf ${TARGET_CPU}-linux-gcc.rul `uname -m`-linux-${TARGET_CPU}-uclibc-gcc.rul ) || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	[ -r DEFAULTS/Defaults.linux.OLD ] || mv DEFAULTS/Defaults.linux DEFAULTS/Defaults.linux.OLD
	cat DEFAULTS/Defaults.linux.OLD \
		| sed '/^INS_BASE=/	s%/.*%'${FR_TH_ROOT}'/usr%' \
		| sed '/^INS_KBASE=/	s%/.*%'${FR_TH_ROOT}'/usr%' \
		> DEFAULTS/Defaults.linux

	make || exit 1
	make install || exit 1

	if [ $0 -nt ${FR_TH_ROOT}/usr/bin/mkisofs ] ; then
		echo "$0: REGRESSION: Failed to build/install mkisofs!" 1>&2
		exit 1
	fi
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
