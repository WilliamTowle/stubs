#!/bin/sh
# 02/10/2004

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

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr --libexecdir=/usr \
		 --build=`uname -m` --host=${TARGET_CPU} \
		 --disable-nls --disable-largefile || exit 1

	[ -r src/main.h.OLD ] || cp src/main.h src/main.h.OLD
	cp src/main.h.OLD src/main.h
	cat <<"EOP" | sed 's/^#//' | patch -i - src/main.h
#12a13
#> #ifdef REENABLE_LARGEFILE
#13a15,17
#> #else
#> extern int nr_inodes;
#> #endif
EOP

	[ -r src/main.c.OLD ] || cp src/main.c src/main.c.OLD
	cp src/main.c.OLD src/main.c
	cat <<"EOP" | sed 's/^#//' | patch -i - src/main.c
#7c7
#< //#include <fcntl.h>
#---
#> #ifdef REENABLE_LARGEFILE
#8a9,11
#> #else
#> #include <fcntl.h>
#> #endif
#30a34
#> #ifdef ENABLE_LARGEFILE
#31a36,40
#> #else
#> #if 0	/* UNUSED */
#> unsigned int nr_inodes = 0;	/* number of FOUND inodes */
#> #endif
#> #endif
#80a90
#> #ifdef REENABLE_LARGEFILE
#81a92,94
#> #else
#> 	if ((i = open(argv[optind], O_RDONLY)) == -1) {
#> #endif
#91a105
#> #ifdef REENABLE_LARGEFILE
#94a109,113
#> #else
#> 	else if (fstat(i, &st) == 0) {
#> 		fs_size = (unsigned long long) st.st_size;
#> 	}
#> #endif
#104a124
#> #ifdef REENABLE_LARGEFILE
#106a127,130
#> #else
#> 	fprintf(stderr, "File `%s' successfully opened with filesize %u bytes.\n",
#> 			argv[optind], fs_size);
#> #endif
#143a168
#> #ifdef REENABLE_LARGEFILE
#144a170,172
#> #else
#> 		if ((i = open(argv[optind], O_RDWR)) == -1) {
#> #endif
EOP

	[ -r src/config.h.OLD ] || cp src/config.h src/config.h.OLD
	cat src/config.h.OLD \
		| sed 's%I_CHECKED_CONFIG 0%I_CHECKED_CONFIG 1%' \
		> src/config.h

#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make prefix=/usr exec_prefix=/usr libexecdir=/usr || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr exec_prefix=${INSTTEMP}/usr libexecdir=${INSTTEMP}/usr install || exit 1
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
