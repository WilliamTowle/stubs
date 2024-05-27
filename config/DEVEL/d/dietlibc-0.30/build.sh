#!/bin/sh
# 06/07/2006

#TODO:- (v0.??) runtime complains of parse errors in 64-bit stuff
#TODO:- (v0.30) runs 'diet'; locating start.o/dietlibc.a fail

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

	case ${PKGVER} in
	0.24)
		LOCATION=/usr/${TARGET_CPU}-linux-dietlibc
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
		cat Makefile.OLD \
			| sed '/$(PICODIR)\// s/^/#/' \
			> Makefile || exit 1

		[ -r findcflags.sh.OLD ] || mv findcflags.sh findcflags.sh.OLD || exit 1
		cat findcflags.sh.OLD \
			| sed 's/-[fm]align-[a-z]*=1//g' \
			> findcflags.sh || exit 1
		chmod a+x findcflags.sh || exit 1
	;;
	0.25|0.26)	# non-optional 64-bit platform support,
			# which uClibc compiler wrapper rejects
		for F in lib/*64*.c ; do mv $F ${F}.OMITTED ; done

		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/ s/gcc/${CCPREFIX}cc/' \
				| sed '/^prefix/ s%.*%prefix=/usr/'${TARGET_CPU}'-linux-dietlibc%' \
				> ${MF} || exit 1
		done
	;;
	0.27|0.28)
		[ -r findcflags.sh.OLD ] || mv findcflags.sh findcflags.sh.OLD || exit 1
		cat findcflags.sh.OLD \
			| sed 's/-[fm]align-[a-z]*=1//g' \
			> findcflags.sh || exit 1
		chmod a+x findcflags.sh || exit 1
	;;
	0.30)
		[ -r findcflags.sh.OLD ] || mv findcflags.sh findcflags.sh.OLD || exit 1
		cat findcflags.sh.OLD \
			| sed 's/-[fm]align-[a-z]*=1//g' \
			> findcflags.sh || exit 1
		chmod a+x findcflags.sh || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	0.24)
			make \
			  CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
			  || exit 1
	;;
	0.25|0.26)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  || exit 1
	;;
	0.27|0.28)
			make \
			  CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
			  || exit 1
	;;
	0.30)
			make \
			  CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
			  || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	0.24)
		make DESTDIR=${INSTTEMP} prefix=${LOCATION} install \
			|| exit 1
		echo '[ {pstart,libgmon}.o aren't built, they're allowed to fail ]'
		echo "[ PICODIR stuff \(we don't \`make dyn either\`\) is commented out to limit warnings ]"
	;;
	0.25|0.26)
		make DESTDIR=${INSTTEMP} install || exit 1
		echo '[ {pstart,libgmon}.o aren't built, they're allowed to fail ]'
		echo "[ PICODIR stuff \(we don't \`make dyn either\`\) is commented out to limit warnings ]"
	;;
	0.27|0.28)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	0.30)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	*)	echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_tc()
{
# CONFIGURE...
echo "UNTESTED" ; exit 1
#	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
#		# Ah, sanity! 2005-11-11 onward
#		PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
#	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
#	fi

	LOCATION=${TCTREE}/usr/${TARGET_CPU}-linux-dietlibc

# BUILD...
	make prefix=${LOCATION} || exit 1

# INSTALL...
	make prefix=${LOCATION} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-cross)
#	INSTTEMP=${TCTREE} make_tc || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
