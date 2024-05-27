#!/bin/sh
# 18/12/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
	if [ -r ${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc ] ; then
		# original sane-gcc-compiler environment
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	elif [ -r ${TCTREE}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc ] ; then
		# sane-gcc-compiler environment, 09/10/2004
		FR_CROSS_CC=${TCTREE}/bin/${TARGET_CPU}-uclibc-linux-gnu-gcc
		FR_LIBCDIR=${TCTREE}
	else
		# uClibc-wrapper build environment
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	fi
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  ac_cv_func_setvbuf_reversed=no \
		./configure --prefix=/usr \
		  --bindir=/bin --localstatedir=/var \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  || exit 1

# | sed '/^DEFS/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/ -g //' \
			> ${MF} || exit 1
	done

# BUILD...
	case ${PKGVER} in
	2.0)
		PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
			make || exit 1
		;;
	2.0.15)
		PATH=${TCTREE}/${FR_UCPATH}/bin:${PATH} \
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
			make || exit 1
		;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	( cd ${INSTTEMP} && ( \
		( cd bin && ln -sf test '[' ) ;\
		mkdir -p var/run ;\
		touch var/run/utmp \
	) || exit 1 ) || exit 1
}

make_th()
{
# CONFIGURE...
	if [ ! -d /usr/include/linux ] ; then
		echo "$0: Confused -- no /usr/src/linux" 1>&2
		exit 1
	fi

	CC=`which gcc` \
		./configure \
		 --prefix=${INSTTEMP}/usr --bindir=${INSTTEMP}/bin \
		 --localstatedir=${INSTTEMP}/var \
		 || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
	( cd ${INSTTEMP} && ( \
		( cd bin && ln -sf test '[' ) ;\
		mkdir -p var/run ;\
		touch var/run/utmp \
	) || exit 1 ) || exit 1
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