#!/bin/sh
# 07/12/2005

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

	CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls --disable-largefile \
		  --without-x --disable-xbr \
		  || exit 1

	# (18/04/2005) Big pile of fixes for NOT building with gcc 3.x
	# (05/08/2006) Need to affect CCDEPMODE=, ideally
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^DEFAULT_INCLUDES/ s%=%= ${XCFLAGS} %' \
			| sed '/^	if/ s/\$@//' \
			| sed '/^	if/ s/-MD//' \
			| sed '/^	if/ s/"[^"]*"//' \
			| sed '/^	if/ s/-M[TPF] //g' \
			| sed '/^	then/ s/fi/fi ; true/' \
			| sed '/^CCDEPMODE/	s/gcc3/gcc/' \
			| sed 's/" = /" == /' \
			> ${MF} || exit 1
	done

	for SF in src/ccrypt.c src/traverse.c ; do
		[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
		cat ${SF}.OLD \
			| sed '/_FILE_OFFSET_BITS/ s/64/32/' \
			> ${SF} || exit 1
	done

# BUILD...
#	make CC=${FR_HOST_CC} -C src maketables || exit 1

#		make XCFLAGS='-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include' \
#		  || exit 1

	make CC=${FR_HOST_CC} -C src maketables || exit 1
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
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
