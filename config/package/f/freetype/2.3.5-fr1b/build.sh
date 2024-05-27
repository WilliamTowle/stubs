#!/bin/sh
# 2008-10-04 (prev. 2005-12-07)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	[ -r config.mk ] && rm config.mk
#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=/usr \
		  --host=`uname -m`-pc-linux-gnu --build=${TARGET_CPU} \
		  || exit 1

# | sed '/^CC/ s%$% -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in builds/unix/*.mk ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/ -g / /' \
			> ${MF} || exit 1
	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	[ -r config.mk ] && rm config.mk
#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=${FR_LIBCDIR} \
		  --host=`uname -m`-pc-linux-gnu --build=${TARGET_CPU} \
		  || exit 1

# | sed '/^CC/ s%$% -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in builds/unix/*.mk ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/ -g / /' \
			> ${MF} || exit 1
	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
	make || exit 1

# INSTALL...
	make DESTDIR='' install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
