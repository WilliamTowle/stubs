#!/bin/sh
# 09/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

#	--build=`uname -m` --host=${TARGET_CPU} --target=${TARGET_CPU} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

# | sed 's%(CC)%(CC) -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^PSRC/ s/=.*/=/' \
			| sed '/^all:/ s/gpm//' \
			| sed '/(CC)/ s/ -g / /' \
			| sed '/INSTALL_PROGRAM/ s/^/#/' \
			> ${MF} || exit 1
	done

# BUILD...

	( cd src &&
			make lib/libgpm.a lib/libgpm.so || exit 1
	) || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/include || exit 1
	mkdir -p ${INSTTEMP}/usr/lib || exit 1
	cp src/headers/gpm.h ${INSTTEMP}/usr/include || exit 1
	cp src/lib/libgpm.a ${INSTTEMP}/usr/lib || exit 1
	if [ -r src/lib/libgpm.so.${PKGVER} ] ; then
		echo "CONFUSED: expected not to file libgpm.so.${PKGVER}" 1>&2
		exit 1
	else
		cp src/lib/libgpm.so.1.19.0 ${INSTTEMP}/usr/lib || exit 1
		( cd ${INSTTEMP}/usr/lib && ln -sf libgpm.so.1.19.0 libgpm.so ) || exit 1
	fi
}

make_tc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

# | sed 's%(CC)%(CC) -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^PSRC/ s/=.*/=/' \
			| sed '/^all:/ s/gpm//' \
			| sed '/(CC)/ s/ -g / /' \
			| sed '/INSTALL_PROGRAM/ s/^/#/' \
			> ${MF} || exit 1
	done

# BUILD...

	( cd src &&
			make lib/libgpm.a lib/libgpm.so || exit 1
	) || exit 1

# INSTALL...
	cp src/headers/gpm.h ${FR_LIBCDIR}/include || exit 1
	cp src/lib/libgpm.a ${FR_LIBCDIR}/lib || exit 1
	if [ -r src/lib/libgpm.so.${PKGVER} ] ; then
		echo "CONFUSED: expected not to file libgpm.so.${PKGVER}" 1>&2
		exit 1
	else
		cp src/lib/libgpm.so.1.19.0 ${FR_LIBCDIR}/lib || exit 1
		( cd ${FR_LIBCDIR}/lib && ln -sf libgpm.so.1.19.0 libgpm.so ) || exit 1
	fi
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
