#!/bin/sh -x
# 2008-02-16 (prev 2008-01-22)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	 CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --disable-nls --disable-largefile \
		  || exit 1

# | sed '/^DEFS/ s%-I.%-nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include -I. %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/CX*FLAGS/ s/ -g //' \
			> ${MF} || exit 1
	done

# BUILD...
	make || exit 1
	mv libtool libtool.OLD || exit 1
	sed 's%'${FR_TH_ROOT}'%%g ; s%'${FR_CROSS_CC}'%/usr/bin/gcc%' libtool.OLD > libtool || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	CC=${FR_HOST_CC} \
	  ./configure --prefix=${FR_TH_ROOT}/usr || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
