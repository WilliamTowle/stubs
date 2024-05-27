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

	# default configure options are '+fhs +lang en'
	# need '+lang none' for -DNONLS if libc lacks cat{open,gets}()
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		./configure +fhs +lang none \
		  || exit 1

#	make man2html/Makefile
#	[ -r man2html/Makefile.OLD ] || cp man2html/Makefile man2html/Makefile.OLD
#	cat man2html/Makefile.OLD \
#		> man2html/Makefile || exit 1

#	make man/Makefile
#	[ -r man/Makefile.OLD ] || cp man/Makefile man/Makefile.OLD
#	cat man/Makefile.OLD \
#		> man/Makefile || exit 1

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		make ${MF} || exit 1
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's%-p /usr/%-p $(PREFIX)/usr/%' \
			> ${MF} || exit 1
	done

# BUILD...
# ...host utilities
	make CC=${FR_HOST_CC} -C src makemsg

# ...now the cross-compilation bit
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CC=${FR_CROSS_CC} || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/sbin
	make PREFIX=${INSTTEMP} install || exit 1
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
