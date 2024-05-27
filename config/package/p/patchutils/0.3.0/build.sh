#!/bin/sh
# 2008-07-06

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		 --disable-nls --disable-largefile || exit 1

# BUILD...
#	PATH=${UCPATH}/bin:${PATH} \
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	case ${PKGVER} in
	0.2.30|0.3.0)
		find ${INSTTEMP} -type f | while read FILE ; do
			case ` head -n 1 ${FILE} | sed 's/ .*//' ` in
			\#!*)	cat ${FILE} | sed "s%${TCTREE}%%" > tmp.$$ \
					|| exit 1
				mv tmp.$$ ${FILE} || exit 1
				chmod a+x ${FILE} || exit 1
			esac
		done
	;;
	*)	echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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
