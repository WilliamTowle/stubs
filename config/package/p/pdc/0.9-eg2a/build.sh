#!/bin/sh
# 11/12/2005

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

	if [ ! -r ${FR_TH_ROOT}/usr/bin/yacc ] ; then
		echo "$0: CONFIGURE: Confused -- no 'yacc'" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_LIBCDIR}/include/readline/readline.h ] ; then
		echo "$0: Confused -- no readline.h" 1>&2
		exit 1
	else
		ADD_INCL_READLINE='-I'${FR_LIBCDIR}'/readline'
	fi

	[ -r ./configure ] && exit 1

#	  CC=${FR_CROSS_CC} \
#	  CFLAGS="-I${FR_LIBCDIR}/include/ncurses" \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-largefile --disable-nls \
#		  || exit 1

### | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/-g$//' \
			| sed '/^HAVE_READLINE/	s%$%'${ADD_INCL_READLINE}'%' \
			> ${MF} || exit 1
	done

# BUILD...

	# (11/12/2005) PATH needs 'yacc'
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make CC=${FR_CROSS_CC} \
		  || exit 1 

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	cp pdc ${INSTTEMP}/usr/local/bin/
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
