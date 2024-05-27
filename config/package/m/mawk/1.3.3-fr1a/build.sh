#!/bin/sh
# 22/12/2005

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

	# assumes FR_CROSS_CC is gcc v2.x
	CC=${FR_CROSS_CC} \
	  CFLAGS=-O2 \
	  MATHLIB=-lm \
		./configure \
		  || exit 1
# --prefix=${FR_TH_ROOT}/usr --exec-prefix=${FR_TH_ROOT}/usr \

# | sed '/^CC/ s%g*cc%'${FR_CROSS_CC}'%' \
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^BINDIR/ s%/usr.*bin%${DESTDIR}/usr/bin%' \
			| sed '/^MANDIR/ s%/usr.*man1%${DESTDIR}/usr/man/man1%' \
			> ${MF} || exit 1
	done
#		| sed '/^	/ s%./mawktest%${SHELL} ./mawktest%' \
#		| sed '/^	/ s%./fpe_test%${SHELL} ./fpe_test%' \

# BUILD...
	# PATH for 'cmp'...
#	PATH=${FR_LIBCDIR}/usr/bin:${PATH}
		make mawk \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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

	case `basename ${SHELL}`-${BASH_VERSION} in
	bash-3.00.*|bash-2.05b.0*)
		CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
		  MATHLIB=-lm \
			./configure \
			  || exit 1
# --prefix=${FR_TH_ROOT}/usr --exec-prefix=${FR_TH_ROOT}/usr \

		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^BINDIR/ s%/usr.*bin%${DESTDIR}/usr/bin%' \
				| sed '/^MANDIR/ s%/usr.*man1%${DESTDIR}/usr/man/man1%' \
				| sed '/^	/ s%./mawktest%${SHELL} ./mawktest%' \
				| sed '/^	/ s%./fpe_test%${SHELL} ./fpe_test%' \
				> ${MF} || exit 1
		done
	;;
	# (22/12/2005) busybox/Willow has /bin/sh
	bash-2*|sh-)
		CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./configure --prefix=${FR_TH_ROOT}/usr --exec-prefix=${FR_TH_ROOT}/usr \
			  || exit 1

		for MF in `find ./ -name Makefile` ; do
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^BINDIR/ s%/usr.*bin%${DESTDIR}/usr/bin%' \
				| sed '/^MANDIR/ s%/usr.*man1%${DESTDIR}/usr/man/man1%' \
				> ${MF} || exit 1
		done
	;;
	*)
		echo "$0: CONFIGURE: Unexpected bash version ${BASH_VERSION}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case `basename ${SHELL}`-${BASH_VERSION} in
	bash-3.00.*)	# 3.00.0(1)-release, SuSE 9.2, has POSIX 'trap'
		# bash 3 very POSIXly strict, use 'ash' for now
		# (28/12/2004) Needs 'cmp' PATHed - dependency
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  make SHELL=`which ash` mawk_and_test || exit 1
	;;
		# (22/12/2005) busybox/Willow has /bin/sh:
	bash-2*|sh-)
		# (28/12/2004) Needs 'cmp' PATHed - dependency
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  make mawk_and_test || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected bash version ${BASH_VERSION}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	mkdir -p ${FR_TH_ROOT}/usr/bin || exit 1
	mkdir -p ${FR_TH_ROOT}/usr/man/man1 || exit 1
	make DESTDIR=${FR_TH_ROOT} install || exit 1

	( cd ${FR_TH_ROOT}/usr/bin && ( \
		ln -sf mawk awk \
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
