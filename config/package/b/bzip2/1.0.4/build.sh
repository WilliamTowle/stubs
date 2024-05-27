#!/bin/sh
# 06/01/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGNAME}-${PKGVER}-${PHASE} in
	bzip2-1.0.3-dc|bzip2-1.0.3-tc|bzip2-1.0.4-[dt]c)
		for MF in Makefile Makefile-libbz2_so ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /^CC=/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed	' /^AR=/	s%ar%'`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'`'%' \
				| sed	' /^RANLIB=/	s%ranlib%'`echo ${FR_CROSS_CC} | sed 's/gcc$/ranlib/'`'%' \
				| sed	' /^BIGFILES=/	s/^/#/' \
				| sed	' /^CFLAGS=/	s/ -g / /' \
				| sed	' /^PREFIX=/	s%=.*%= ${DESTDIR}/usr%' \
				| sed	' /^all:/	s/test//' \
				| sed	' /^	ln /	s/ / -sf /' \
				> ${MF} || exit 1
		done
	;;
	bzip2-1.0.3-th|bzip2-1.0.4-th)
		for MF in Makefile Makefile-libbz2_so ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /^CC=/	s%g*cc%'${FR_HOST_CC}'%' \
				| sed	' /^AR=/	s%ar%'`echo ${FR_HOST_CC} | sed 's/gcc$/ar/'`'%' \
				| sed	' /^RANLIB=/	s%ranlib%'`echo ${FR_HOST_CC} | sed 's/gcc$/ranlib/'`'%' \
				| sed	' /^BIGFILES=/	s/^/#/' \
				| sed	' /^CFLAGS=/	s/ -g / /' \
				| sed	' /^PREFIX=/	s%=.*%= '${FR_TH_ROOT}'/usr%' \
				| sed	' /^all:/	s/test//' \
				| sed	' /^	ln /	s/ / -sf /' \
				> ${MF} || exit 1
		done
	;;
	*)
		echo "$0: do_configure(): Unexpected PKGNAME/PKGVER/PHASE ${PKGNAME} ${PKGVER} ${PHASE}" 1>&2
		exit 1
	;;
	esac
}

do_post_install()
{
	# binaries
	mkdir -p ${MINIMAL_INSTTEMP}/bin || exit 1
	( cd ${MINIMAL_INSTTEMP}/usr/bin || exit 1
		rm -f bunzip2 bzcat || exit 1
		ln -sf bzip2 bunzip2 || exit 1
		ln -sf bzip2 bzcat || exit 1
		mv bzip2 bunzip2 bzcat ../../bin/ || exit 1
		rm -f bzcmp bzegrep bzfgrep bzless || exit 1
		ln -sf bzdiff bzcmp || exit 1
		ln -sf bzgrep bzegrep || exit 1
		ln -sf gzgrep bzfgrep || exit 1
		ln -sf bzmore bzless || exit 1
	) || exit 1

	# libraries/utils
	mkdir -p ${UTILS_INSTTEMP}/usr || exit 1
	mv ${MINIMAL_INSTTEMP}/usr/bin ${UTILS_INSTTEMP}/usr/ || exit 1
	mv ${MINIMAL_INSTTEMP}/usr/include ${UTILS_INSTTEMP}/usr/ || exit 1
	mv ${MINIMAL_INSTTEMP}/usr/lib ${UTILS_INSTTEMP}/usr/ || exit 1
	mv libbz2.so* ${UTILS_INSTTEMP}/usr/lib || exit 1
	( cd ${UTILS_INSTTEMP}/usr/lib || exit 1
		ln -sf libbz2.so.${PKGVER} libbz2.so
	) || exit 1

	# manuals
	mkdir -p ${UTILS_INSTTEMP}/usr/man/man1 || exit 1
	( cd ${MINIMAL_INSTTEMP}/usr/man/man1 || exit 1
		echo '.so man1/bzip2.1' > bunzip2.1 || exit 1
		echo '.so man1/bzip2.1' > bzcat.1 || exit 1
		mv bzcmp.1 bzdiff.1 bzgrep.1 bzegrep.1 bzfgrep.1 bzless.1 bzmore.1 ${UTILS_INSTTEMP}/usr/man/man1/ || exit 1
	) || exit 1
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

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		case ${PKGVER} in
		1.0.3)
			for PF in *patch ; do
				cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
			done
		;;
		esac
		cd ${PKGNAME}-${PKGVER} || exit 1
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
	make || exit 1
	make -f Makefile-libbz2_so || exit 1

# INSTALL...
	make DESTDIR=${MINIMAL_INSTTEMP} install || exit 1
	PHASE=dc do_post_install || exit 1
}

make_tc()
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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER} || exit 1
	fi

	PHASE=tc do_configure || exit 1

# BUILD...

	make libbz2.a || exit 1

# INSTALL...
	#mkdir -p ${FR_LIBCDIR}/lib/ || exit 1
	cp bzlib.h ${FR_LIBCDIR}/include || exit 1
	cp libbz2.a ${FR_LIBCDIR}/lib || exit 1
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

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER} || exit 1
	fi

	PHASE=th do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
