#!/bin/sh
# 13/09/2005

#TODO:- parse errors before 'size_t' :(

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

	[ -r src/Config.OLD ] || mv src/Config src/Config.OLD || exit 1
#	cat src/Config.OLD \
#		| sed '/^CC=/ s%gcc%${CCPREFIX}cc -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
#		| sed '/^CPP=/ s%gcc%${CCPREFIX}cc -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
#		> src/Config || exit 1
	cat src/Config.OLD \
		| sed '/^CC=/ s%gcc%${CCPREFIX}cc%' \
		| sed '/^CPP=/ s%gcc%${CCPREFIX}cc%' \
		> src/Config || exit 1

	for SF in \
			src/include/endian.h  \
			src/include/byteswap.h \
			src/include/string.h ; do
		mv ${SF} ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed 's%bits/byteswap.h%byteswap.h%' \
			| sed 's%bits/endian.h%endian.h%' \
			| sed 's%bits/string.h%string.h%' \
			> ${SF} || exit 1
	done

# BUILD...
	case ${PKGVER} in
	5.2.*)
		( cd src &&
			PATH=${FR_LIBCDIR}/bin:${PATH} \
				make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` all || exit 1
		) || exit 1
		;;
	5.3.9)
		( cd src &&
			PATH=${FR_LIBCDIR}/bin:${PATH} \
				make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` all || exit 1
		) || exit 1
		;;
	5.4.0|5.4.1|5.4.2)
		( cd src &&
			# PATH=${FR_LIBCDIR}/bin:${PATH}
			# try to fix "size_t" with -D_I386_STRING_H_ - failed
				make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
				  EXTRA_CFLAGS="-D_I386_STRING_H_" \
				  all || exit 1
		) || exit 1
		;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1 ;;
#		( cd src &&
#			PATH=${FR_LIBCDIR}/bin:${PATH} \
#				make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` allzdsks || exit 1
#		) || exit 1
	esac \
		|| exit 1

# INSTALL...
echo "... :) ... INSTALL now" ; exit 1
	#make DESTDIR=${INSTTEMP} install || exit 1
	mkdir -p ${INSTTEMP}/opt/${PKGNAME}-${PKGVER}/ || exit 1
	cp src/bin/*img ${INSTTEMP}/opt/${PKGNAME}-${PKGVER}/ || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
