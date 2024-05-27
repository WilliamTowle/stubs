#!/bin/sh -x
# 12/03/2006

#TODO:- syntax error in 'twstart' script

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

#do_endianity_fix()
#{
#	[ -r scripts/endianity.c.OLD ] || mv scripts/endianity.c scripts/endianity.c.OLD || exit 1
#	( 	echo '#include <sys/param.h>'
#		echo '#include <endian.h>'
#
#		sed '	s/\\/\\\\/g ; s/"/\\"/g
#			; s/^/echo "/
#			; s/$/"/
#
#			; s/getpagesize(),"/" EXEC_PAGESIZE "," /
#			; s/byte_order"/" \\"__BYTE_ORDER\\" /
#			' scripts/endianity.c.OLD
#	) | ${FR_CROSS_CC} -E - | grep '^echo' > tmp.sh
#	sh tmp.sh > scripts/endianity.c
#}
#
#do_getsizes_fix()
#{
#	[ -r scripts/getsizes.c.OLD ] || mv scripts/getsizes.c scripts/getsizes.c.OLD || exit 1
#	sed '	/include </ s/^/#define ECHO /
#		; /autoconf.h/ s/^/#define ECHO /
#		; /define ECHO/ s/$/\nECHO\n/
#		' scripts/getsizes.c.OLD > tmp$$.c || exit 1
#	${FR_CROSS_CC} -I${FR_KERNSRC}/include/linux -Iinclude -DHAVE_SYS_PARAM_H -E tmp$$.c > scripts/getsizes.c || exit 1
#	rm -f tmp$$.c
#}

make_dc()
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

#	CC=${FR_CROSS_CC} \
#	  ac_cv_func_setvbuf_reversed=no \
#	  ac_cv_file__dev_ptmx=no \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
#		  || exit 1
	CC=${FR_CROSS_CC} \
	  ac_cv_file__dev_ptmx=no \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
		  --enable-tt=yes \
		  --enable-tt-hw-x11=no \
		  --enable-hw-termcap=yes \
		  || exit 1

#	case ${PKGVER} in
#	0.5.1)
#		[ -r makerules.in.OLD ] || mv makerules.in makerules.in.OLD || exit 1
#		sed '/endianity:/,+2 d' makerules.in.OLD \
#			| sed 's%$(CC)%'${FR_HOST_CC}'%' \
#			> makerules.in || exi t1
#
#		do_endianity_fix
#		do_getsizes_fix
#	;;
#	*)
#		echo "$0: CONFIGURE(): Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#	;;
#	esac

# BUILD...
	if [ -r ${FR_TH_ROOT}/usr/bin/gmake ] ; then
		${FR_TH_ROOT}/usr/bin/gmake
	else
		make || exit 1
	fi

# INSTALL...
	#make prefix=${FR_TH_ROOT} install || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

#make_tc()
#{
## CONFIGURE...
#	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
#		# Ah, sanity! 2005-11-11 onward
#		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
#	else
##		echo "$0: CONFIGURE: Configuration not determined" 1>&2
#		if [ -d ${TCTREE}/cross-utils ] ; then
#			FR_TC_ROOT=${TCTREE}/cross-utils
#			FR_TH_ROOT=${TCTREE}/host-utils
#		else
#			FR_TC_ROOT=${TCTREE}/
#			FR_TH_ROOT=${TCTREE}/
#		fi
#
#		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
#		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
#		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
#			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
#		else
#			FR_HOST_CC=`which gcc`
#		fi
#		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
#	fi
#
#	CC=${FR_CROSS_CC} \
#	  ac_cv_func_setvbuf_reversed=no \
#	  ac_cv_file__dev_ptmx=no \
#		./configure --prefix=${FR_TH_ROOT}/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  || exit 1
#
#	case ${PKGVER} in
#	0.5.1)
#		[ -r makerules.in.OLD ] || mv makerules.in makerules.in.OLD || exit 1
#		sed '/endianity:/,+2 d' makerules.in.OLD \
#			| sed 's%$(CC)%'${FR_HOST_CC}'%' \
#			> makerules.in || exi t1
#
#		do_endianity_fix
#		do_getsizes_fix
#	;;
#	*)
#		echo "$0: CONFIGURE(): Unexpected PKGVER ${PKGVER}" 1>&2
#		exit 1
#	;;
#	esac
#
## BUILD...
#	if [ -r ${FR_TH_ROOT}/usr/bin/gmake ] ; then
#		gmake || exit 1
#	else
#		make || exit 1
#	fi
#
## INSTALL...
#	#make prefix=${FR_TH_ROOT} install || exit 1
#	make install || exit 1
#}

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
