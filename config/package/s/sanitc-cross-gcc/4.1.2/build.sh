#!/bin/sh -x
# 12/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d uclibc ] ; then
		echo "...Patching [Gentoo]..."
		for PF in uclibc/*patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
#		cd gcc-${PKGVER}
	else
		echo "...Patching [LFS]..."
		for PF in *patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
	fi

	CC=${FR_HOST_CC} \
		./gcc-${PKGVER}/configure -v \
		  --prefix=${FR_TC_ROOT}/usr \
		  --host=${FR_HOST_DEFN} \
		  --target=${FR_TARGET_DEFN} \
		  --enable-clocale=uclibc \
		  --program-prefix=${FR_TARGET_DEFN}- \
		  --with-sysroot=${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}/ \
		  --with-local-prefix=${FR_TC_ROOT}/usr/ \
		  --enable-languages=c \
		  --disable-__cxa_atexit \
		  --disable-nls \
		  --disable-libmudflap \
		  --disable-libssp \
		  --enable-shared \
		  || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	PHASE=th do_configure

# BUILD...
	# (02/09/2006) PATH requires binutils
	PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
		make || exit 1

# INSTALL...
	make install || exit 1
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
