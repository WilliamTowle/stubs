#!/bin/sh
# 29/11/2005

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
	1.2.4*)
	# ...configure is a simplified workalike
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  CFLAGS=-Os \
			./configure --prefix=/usr || exit 1
	;;
	1.3.5)
		PATH=${FR_LIBCDIR}/bin:${PATH} \
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1
	;;
	1.3.12)
#		path=${fr_libcdir}/bin:${path}
		  CC=${FR_CROSS_CC} \
		  CFLAGS='-O2' \
			./configure --prefix=/usr --datarootdir=/usr \
			  --host=`uname -m` --build=${target_cpu} \
			  --disable-nls --disable-largefile \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	[ -r gzexe.in.OLD ] || mv gzexe.in gzexe.in.OLD || exit 1
	cat gzexe.in.OLD \
		| sed 's%"BINDIR"%/bin%' \
		> gzexe.in || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	mkdir -p ${UTILS_INSTTEMP}/usr/bin || exit 1
	mkdir -p ${UTILS_INSTTEMP}/usr/man/man1 || exit 1
	case ${PKGVER} in
	1.2.4*|1.3.5)
		make prefix=${UTILS_INSTTEMP}/usr install || exit 1
	;;
	1.3.12)
		make DESTDIR=${UTILS_INSTTEMP} install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	mkdir -p ${MINIMAL_INSTTEMP}/bin || exit 1
	( cd ${UTILS_INSTTEMP}/usr/bin &&
		mv gzip ${MINIMAL_INSTTEMP}/bin
		[ -r gunzip ] && rm gunzip
		[ -r zcat ] && rm zcat
		[ -r zdiff ] && rm zdiff
		ln -sf zcmp zdiff
	) || exit 1
	( cd ${MINIMAL_INSTTEMP}/bin &&
		ln -sf gzip gunzip
		ln -sf gzip zcat
	) || exit 1

	mkdir -p ${MINIMAL_INSTTEMP}/usr/man/man1 || exit 1
	( cd ${UTILS_INSTTEMP}/usr/man/man1 &&
		for M in gunzip.1 gzip.1 zcat.1 ; do
			mv $M ${MINIMAL_INSTTEMP}/usr/man/man1/$M || exit 1
		done
	) || exit 1

	( cd ${MINIMAL_INSTTEMP}/usr && rm -rf info )
	mv ${UTILS_INSTTEMP}/usr/info/ ${MINIMAL_INSTTEMP}/usr || exit 1
}

make_th()
{
# CONFIGURE...
	# sanitc 27/06/2005+
	if [ -d ${INSTTEMP}/host-utils ] ; then
		FR_TH_PATH=${INSTTEMP}/host-utils
	else
		FR_TH_PATH=${INSTTEMP}
	fi
	if [ -r ${FR_TH_PATH}/usr/bin/gcc ] ; then
		FR_HOST_CC=${FR_TH_PATH}/usr/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	CC=${FR_HOST_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=${FR_TH_PATH}/ \
		  || exit 1

	if [ ! -r gzexe.in.OLD ] ; then \
		cp gzexe.in gzexe.in.OLD ;\
		sed 's%"BINDIR"%/bin%' gzexe.in.OLD > gzexe.in ;\
	fi

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
	( cd ${FR_TH_PATH}/bin && ( \
		[ -r gunzip ] && rm gunzip ;\
		ln -sf gzip gunzip ;\
		[ -r zcat ] && rm zcat ;\
		ln -sf gzip zcat ;\
		[ -r zdiff ] && rm zdiff ;\
		ln -sf zcmp zdiff ;\
		for FILE in znew zmore zgrep zforce zdiff zcmp gzexe ; do \
			[ -r ../usr/bin/${FILE} ] && rm ../usr/bin/${FILE} ;\
			mv ${FILE} ../usr/bin/ ;\
		done
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
