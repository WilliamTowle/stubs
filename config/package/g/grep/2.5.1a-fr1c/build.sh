#!/bin/sh
# 07/06/2006

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

# ...first, fix the test for whether slash works in filenames (ie.
# unix versus DOS box): verbatim, it assumes /bin/sh is bash - not
# necessarily true.
	[ -r configure.OLD ] || mv configure configure.OLD || exit 1
	SQ="'"
	sed 's%".\\."%'${SQ}'.\\.'${SQ}'%' configure.OLD \
		> configure || exit 1
	chmod a+x configure

# ...CPPFLAGS setting as suggested for glibc=2.1.x:
	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CPPFLAGS="-Dre_max_failures=re_max_failures2" \
	  CC=${FR_CROSS_CC} \
	  CFLAGS=-O2 \
		./configure --prefix=/usr --bindir=/bin \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --disable-perl-regexp \
		  || exit 1

	[ -r lib/regex.c.OLD ] \
		|| cp lib/regex.c lib/regex.c.OLD || exit 1
	cat lib/regex.c.OLD \
		| sed 's/gettext//' \
		> lib/regex.c || exit 1

# ...Hack for configure's assumption that having mbrtowc() implies wcscoll()
# is available too; this is bogus for old/small libc implementations.
	[ -r src/dfa.c.OLD ] || cp src/dfa.c src/dfa.c.OLD || exit 1
	cat src/dfa.c.OLD \
		| sed 's%^# *define MBS_SUPPORT%/* #define MBS_SUPPORT */%' \
		> src/dfa.c || exit 1

# | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
# | sed '/^CFLAGS/ s/ -g //' \
	# nostdinc: No DEFAULT_INCLUDES vs INCLUDES consistency :(
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's%ln -s %ln -sf %' \
			> ${MF} || exit 1
	done

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1
	
# INSTALL...
	make prefix=${INSTTEMP}/usr bindir=${INSTTEMP}/bin install || exit 1
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

# ...first, fix the test for whether slash works in filenames (ie.
# if this is a DOS box) - verbatim, it assumes we have bash.
	[ -r configure.OLD ] || mv configure configure.OLD || exit 1
	SQ="'"
	sed 's%".\\."%'${SQ}'.\\.'${SQ}'%' configure.OLD > configure || exit 1
	chmod a+x configure

# ...CPPFLAGS setting suggested for glibc=2.1.x:
	CC=${FR_HOST_CC} \
	  CPPFLAGS="-Dre_max_failures=re_max_failures2" \
	  CFLAGS='-O2' \
		./configure --prefix=${FR_TH_ROOT}/usr \
		  --bindir=${FR_TH_ROOT}/bin \
		  --disable-nls \
		  --disable-perl-regexp \
		  || exit 1

# ...Hack for configure's assumption that having mbrtowc() implies wcscoll()
# is available too; this is bogus for old/small libc implementations.
	[ -r src/dfa.c.OLD ] || cp src/dfa.c src/dfa.c.OLD || exit 1
	cat src/dfa.c.OLD \
		| sed 's%^# *define MBS_SUPPORT%/* #define MBS_SUPPORT */%' \
		> src/dfa.c || exit 1

	# nostdinc: No DEFAULT_INCLUDES vs INCLUDES consistency :(
	find ./ -name [Mm]akefile | while read MF ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's%ln -s %ln -sf %' \
			| sed '/^	.*--info-dir/	s/install-info/true/' \
			> ${MF} || exit 1
#			| sed '/^	.*--info/	s/install-info /install-info --backup=none /' \
	done

# BUILD...
	make || exit 1
	
# INSTALL...
	make prefix=${FR_TH_ROOT}/usr bindir=${FR_TH_ROOT}/bin install || exit 1
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
