#!/bin/sh
# 22/01/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	./configure --prefix=/usr || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	for F in ${INSTTEMP}/usr/bin/* ; do
		cp ${F} tmp.$$ || exit 1
		sed "s%${TCTREE}%%g" tmp.$$ > ${F} || exit 1
		rm tmp.$$
	done
}

make_th()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config --force

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
