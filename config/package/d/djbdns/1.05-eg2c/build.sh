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

	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/sed / s/}/%/g' \
		| sed 's%./auto-str%./bin/auto-str%' \
		| sed 's%./chkshsgr%./bin/chkshsgr%' \
		| sed 's%./install%./bin/install%' \
		| sed 's%./instcheck%./bin/instcheck%' \
		| sed '/^	/	s/head -1/head -n 1/' \
		> Makefile || exit 1

# | sed 's%^gcc%${CCPREFIX}cc -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r conf-cc.OLD ] || mv conf-cc conf-cc.OLD || exit 1
	cat conf-cc.OLD \
		| sed 's%^gcc%'${FR_CROSS_CC}'%' \
		> conf-cc || exit 1

	[ -r conf-ld.OLD ] || mv conf-ld conf-ld.OLD || exit 1
	cat conf-ld.OLD \
		| sed 's/^gcc/${CCPREFIX}cc/' > conf-ld || exit 1

	[ -r conf-home.TPL ] || mv conf-home conf-home.TPL || exit 1
	[ -r hier.c.TPL ] || mv hier.c hier.c.TPL || exit 1

# BUILD...
# ...tools
	sed "s%^/usr/local%${INSTTEMP}/usr/local%" conf-home.TPL \
		> conf-home || exit 1
	sed 's%"/"%"'${INSTTEMP}'"%' hier.c.TPL > hier.c || exit 1
	mkdir -p bin || exit 1

	# auto-str needs to be first, due to dependencies:
	for PROG in auto-str chkshsgr install instcheck ; do
		make CCPREFIX=`echo ${FR_HOST_CC} | sed 's/cc$//'` ${PROG} \
		  || exit 1
		cp ${PROG} bin/ || exit 1
	done

# ...clean up...
	rm *.o *.a || exit 1

# ...and rebuild things for target environment:
	sed 's%^/usr/local%/usr/local%' conf-home.TPL \
		> conf-home || exit 1
	sed 's%"/"%"/"%' hier.c.TPL > hier.c || exit 1
# INCLUDES="-nostdinc -I${FR_LIBCDIR}/include -I${TCTREE}/usr/lib/gcc-lib/`uname -m`-linux/2.95.3/include -I${TCTREE}/usr/include" \
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make \
		 CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		 it || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/etc || exit 1
	mkdir -p ${INSTTEMP}/usr/local || exit 1
	make setup || exit 1
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
