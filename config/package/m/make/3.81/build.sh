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

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  CFLAGS=-O2 \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

## | sed '/^DEFAULT_INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#	for MF in `find ./ -name Makefile` ; do
#		mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/ -g //' \
#			> ${MF} || exit 1
#	done

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
	( cd ${INSTTEMP}/usr/bin && ln -sf make gmake )
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

# CFLAGS='-nostdinc -I/usr/include -I'${GCCINCDIR}' -O2' \
	CC=${FR_HOST_CC} \
	  AR=`echo ${FR_HOST_CC} | sed 's/gcc$/ar/'` \
		./configure --prefix=${FR_TH_ROOT}/usr \
		  --disable-largefile --disable-nls \
		  || exit 1

	find ./ -name '[Mm]akefile' | while read MF ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS *=/ s/ -g //' \
			| sed '/^	/ s/install-info/install-info --backup=none/' \
			> ${MF} || exit 1
	done

#	if [ -r /lib/ld-linux.so.1 ] ; then
#		# /usr/include/glob.h from gnulibc1 is old and unsuitable. Adjust.
#		[ -r glob/glob.c.OLD ] || mv glob/glob.c glob/glob.c.OLD || exit 1
#		cat glob/glob.c.OLD \
#			| sed 's%<glob.h>%"./glob.h"%' \
#			> glob/glob.c || exit 1
#		for SF in dir.c read.c glob/glob.c ; do
#			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
#			cat ${SF}.OLD \
#				| sed 's%<glob.h>%"glob/glob.h"%' \
#				> ${SF} || exit 1
#		done
#	fi

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
	( cd ${FR_TH_ROOT}/usr/bin && ln -sf make gmake )
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
