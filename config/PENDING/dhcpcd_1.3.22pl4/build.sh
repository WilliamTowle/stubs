#!/bin/sh -x
# 2008-09-21

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
#		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

#	if [ ! -r ${FR_LIBCDIR}/lib/libssl.so.0 ] ; then
#		echo "No libssl build" 1>&2
#		exit 1
#	fi

	case ${PKGVER} in
	1.3.22-pl4)
		CC=${FR_CROSS_CC} \
		  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
			  --disable-nls \
			  --with-included-regex \
			  || exit 1
#			./configure --prefix=/usr \

		[ -r client.c.OLD ] || mv client.c client.c.OLD || exit 1
		cat client.c.OLD \
			| sed '/TR_MAXRIFLEN/ s/- TR_MAXRIFLEN//' \
			> client.c || exit 1
		[ -r dhcpconfig.c.OLD ] || mv dhcpconfig.c dhcpconfig.c.OLD || exit 1
		cat dhcpconfig.c.OLD \
			| sed '/kversion.h/ s%$%\n#ifdef OLD_LINUX_VERSION\n#include <linux/if_packet.h>\n#endif%' \
			> dhcpconfig.c || exit 1

#		[ -r kversion.h.OLD ] || mv kversion.h kversion.h.OLD || exit 1
#		cat kversion.h.OLD \
#			| sed '/OLD_LINUX_VERSION/ { s%^%/* % ; s%$% */% }' \
#			> kversion.h || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LIBC_NCURSES} || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
