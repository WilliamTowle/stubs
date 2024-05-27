#!/bin/sh -x
# 2007-08-04

#TODO:- correct determination of FR_HOST_CC
#TODO:- whether configure needs 'bfd_cv_has_long_long=yes'?

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	if [ -r gcc-2.95.3-2.patch ] ; then
		( cd gcc-${PKGVER} && patch -Np1 -i ../gcc-2.95.3-2.patch || exit 1 )
	fi

# (01/01/2006) Adjust host definition accordingly; leave target alone?
	if [ -r /lib/ld-linux.so.1 ] ; then
		FR_HOST_DEFN=${FR_HOST_DEFN}'-gnulibc1'
	fi
	GNU_TARGET_DEFN=`echo ${FR_TARGET_DEFN} | sed 's/-linux-uclibc/-uclibc-linux/'`
	( cd ${FR_TC_ROOT}/usr || exit 1
		[ -r ${GNU_TARGET_DEFN} ] || ln -sf ${FR_TARGET_DEFN} ${GNU_TARGET_DEFN}
	) || exit 1

#	PATH=${FR_TC_ROOT}/usr/bin:${PATH}
	  CC=${FR_HOST_CC} \
		./gcc-${PKGVER}/configure -v \
		  --prefix=${FR_TC_ROOT}/usr \
		  --target=${FR_TARGET_DEFN} \
		  --enable-languages=c \
		  --disable-nls \
		  --enable-shared \
		  --with-headers=${FR_TC_ROOT}'/usr/'${FR_TARGET_DEFN}'/usr/include' \
		  --with-libs=${FR_TC_ROOT}'/usr/'${FR_TARGET_DEFN}'/usr/lib' \
		  || exit 1

# BUILD...
	# (02/09/2006) PATH requires binutils
	PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
		make || exit 1

# INSTALL...
	# (02/09/2006) 'make install' PATH requires binutils (!!)
	PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
		make install || exit 1
	if [ -r ${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}/lib/crt1.o ] ; then
		cat gcc/specs \
			| sed 's/ld-linux.so.2/ld-uClibc.so.0/' > `${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc -v 2>&1 | grep specs | sed 's/.* //'` || exit 1 ;\
	else
		cat gcc/specs \
			| sed 's/ld-linux.so.2/ld-uClibc.so.0/ ; s/:g*crt1.o/:crt0.o/g' \
			> `${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc -v 2>&1 | grep specs | sed 's/.* //'` || exit 1
	fi
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
