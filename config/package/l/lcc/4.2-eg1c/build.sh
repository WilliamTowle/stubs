#!/bin/sh
# 07/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	mkdir -p ${BUILDDIR} || exit 1
	( cd ${BUILDDIR} &&
		sed '/^[rclb][a-z]*:.*E$/ s/^/#/' ../makefile \
			| sed 's%lburg/%LBURG/%g' \
			| sed 's/-Ilburg/-ILBURG/' \
			> Makefile || exit 1
		ln -s ../lburg ./LBURG || exit 1
		for F in custom.mk etc cpp lib src ; do
			ln -s ../${F} ./ || exit 1
		done

		# etc/linux.c has LCCDIR and {as,ld} locations - by
		# default this is /usr/bin/
		[ -r etc/linux.c.OLD ] || mv etc/linux.c etc/linux.c.OLD || exit 1
		cat etc/linux.c.OLD \
			| sed '/define LCCDIR/ s%"/%"'${ROOTPATH}'%' \
			> etc/linux.c || exit 1
	) || exit 1
}

do_install()
{
	mkdir -p ${INSTTEMP}/usr/local/man/man1 || exit 1
	cp doc/*.1 ${INSTTEMP}/usr/local/man/man1/ || exit 1

	mkdir -p ${INSTTEMP}/usr/local/include || exit 1
	cp -p -R include/x86/linux/* ${INSTTEMP}/usr/local/include/ || exit 1

	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	cp ${BUILDDIR}/lcc ${INSTTEMP}/usr/local/bin || exit 1

	mkdir -p ${INSTTEMP}/usr/local/lib/lcc/ || exit 1

#	( cd ${INSTTEMP}/usr/local/lib/lcc &&
#		ln -s ${GCCLIBDIR} gcc || exit 1
#	) || exit 1
	( cd ${INSTTEMP}/usr/local/lib/lcc &&
		grep '^#cpp' ${0} | sed 's/#cpp#.//' \
			> lcc-cpp.sh || exit 1
		chmod a+x lcc-cpp.sh || exit 1
		( mkdir gcc && cd gcc && ln -s ../lcc-cpp.sh cpp ) \
			|| exit 1
	) || exit 1

	for F in rcc liblcc.a ; do
		cp ${BUILDDIR}/`basename $F` ${INSTTEMP}/usr/local/lib/lcc/$F || exit 1
	done

	rm -rf ${BUILDDIR}
}

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

	for MF in `find ./ -name [Mm]akefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/ s/cc/${CCPREFIX}cc/' \
			> ${MF} || exit 1
	done

# BUILD...
	BUILDDIR=`pwd`/tmp.$$
	ROOTPATH=/ do_configure || exit 1

	( cd ${BUILDDIR} &&
		make CCPREFIX=`echo ${FR_HOST_CC} | sed 's/cc$//'` \
		  BUILDDIR=. \
		  HOSTFILE=etc/linux.c \
		  lburg \
		  || exit 1

		# redundant?  PATH=${FR_LIBCDIR}/bin:${PATH} ...
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  BUILDDIR=. \
		  HOSTFILE=etc/linux.c \
		  all \
		  || exit 1
	) || exit 1

# INSTALL...
	do_install || exit 1
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

#cpp#	#!/bin/sh
#cpp#	# Wrapper script, by WmT 28/06/2004
#cpp#	
#cpp#	# TODO: Only needs 'gcc' for its preprocessor; 
#cpp#	# ...gpp, or other preprocessor instead...? 
#cpp#	#	[ -r /usr/bin/gpp ] ...then... /usr/bin/gpp -C ${*}
#cpp#	
#cpp#	GCCBIN=/usr/bin/gcc
#cpp#	
#cpp#	if [ -r ${GCCBIN} ] ; then
#cpp#		# suss some directories out
#cpp#		LCCLIB=`dirname $0`
#cpp#		GCCDIR=`${GCCBIN} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs//'`
#cpp#	
#cpp#		# make symlinks so as to use this gcc's files - if not done already
#cpp#		if [ ! -r ${LCCLIB}/include ] ; then
#cpp#			for F in ${GCCDIR}/* ; do
#cpp#				[ `basename ${F}` != 'cpp' ] && ln -s ${F} ${LCCLIB}
#cpp#			done
#cpp#		fi
#cpp#	
#cpp#		if [ -r ${GCCDIR}/cpp ] ; then
#cpp#			# use the 'cpp' 'lcc' expected, if it exists
#cpp#			${GCCDIR}/cpp ${*}
#cpp#		else
#cpp#			# reaches here if gcc not installed properly
#cpp#			echo "$0: Confused -- try gcc -E ${*}?" 1>&2
#cpp#			exit 1
#cpp#		fi
#cpp#	else
#cpp#		echo "$0: gcc not installed. Confused..." 1>&2
#cpp#		exit 1
#cpp#	fi
