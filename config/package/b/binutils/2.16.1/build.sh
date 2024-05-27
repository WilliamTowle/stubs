#!/bin/sh
# 17/06/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

#TODO:- willow claims undefined references to fputc*()

make_dc()
{
# CONFIGURE...
	if [ -d ${TCTREE}/host-utils ] ; then
		FR_TH_ROOT=${TCTREE}/host-utils
		FR_TC_ROOT=${TCTREE}/cross-utils
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
	else
		FR_TH_ROOT=${TCTREE}/
		FR_TC_ROOT=${TCTREE}/
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
	fi

	if [ -r ${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc-mk2' compiler environment, 29/09/2005
		FR_LIBCDIR=${FR_TC_ROOT}
		FR_CROSS_CC=${FR_LIBCDIR}/usr/bin/${TARGET_CPU}-cross-linux-gcc
#		GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`
	elif [ -d ${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc/bin ] ; then
		# uClibc-wrapper build environment
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		#FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
		FR_CROSS_CC=${FR_LIBCDIR}/usr/bin/gcc
#		HOST_CPU=`uname -m`
#		eval "GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed s/specs/include/ | sed s/host-/cross-/g | sed s/${HOST_CPU}/${TARGET_CPU}/`"
	else
		echo "$0: Confused -- FR_LIBCDIR not determined" 1>&2
		exit 1
	fi

	HOST_SYS=`uname -s | tr A-Z a-z`

	# PATH=${UCPATH}/bin:${PATH}
	 CC=${FR_CROSS_CC} \
	 AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
		./configure \
		  --prefix=/usr \
		  --host=`uname -m`-pc-${HOST_SYS} --build=${TARGET_CPU}-pc-linux \
		  --target=${TARGET_CPU}-pc-linux \
		  --disable-nls --disable-largefile \
		  || exit 1

	# obsolete since 2.16 onward:
#	for MF in ` find ./ -name Makefile ` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^MAKEINFO/ s%=.*%= true%' \
#			| sed '/do-install-info:/ s/^/#/' \
#			| sed '/dir.info:/ s/^/#/' \
#			| sed '/^CFLAGS/ s/ -g / /' \
#			| sed '/^CFLAGS=/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
	# PATH=${UCPATH}/bin:${PATH}
		make || exit 1

# INSTALL...
	# PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH}
		make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	# sanitc 27/06/2005+
	if [ -d ${INSTTEMP}/host-utils ] ; then
		FR_TH_PATH=${INSTTEMP}/host-utils
	else
		FR_TH_PATH=${INSTTEMP}
	fi
	if [ -r ${FR_TH_PATH}/usr/bin/gcc ] ; then
		FR_HOST_CC=${FR_TH_PATH}/usr/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	CC=${FR_HOST_CC} \
		./configure \
		  --prefix=${INSTTEMP}/usr \
		  --disable-nls --disable-largefile \
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
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
