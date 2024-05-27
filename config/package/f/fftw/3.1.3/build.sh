#!/bin/sh
# 2008-10-12

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  ac_cv_sizeof_short=2 \
	  ac_cv_sizeof_int=4 \
	  ac_cv_sizeof_long=4 \
	  ac_cv_sizeof_long_long=8 \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --with-pcap=linux \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  ac_cv_sizeof_short=2 \
	  ac_cv_sizeof_int=4 \
	  ac_cv_sizeof_long=4 \
	  ac_cv_sizeof_long_long=8 \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=${FR_LIBCDIR} \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --with-pcap=linux \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	exit 1
;;
esac
