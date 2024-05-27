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

	for F in Makefile src/Makefile ; do
		[ -r ${F}.OLD ] || mv ${F} ${F}.OLD || exit 1
	done

	cat Makefile.OLD \
		| sed 's%/usr%${DESTROOT}/usr%' \
		> Makefile || exit 1

	# don't build cmos{dis,fd,hd}type - we lack linux/nvram.h
	# also COPY the executables, or will attempt rebuild with 'cc'
# | sed '/^CFLAGS	/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	cat src/Makefile.OLD \
		| sed '/^CC	/ s%gcc%'${FR_CROSS_CC}'%' \
		| sed '/^PROGS/ s/cmosdistype//' \
		| sed '/^PROGS/ s/cmosfdtype//' \
		| sed '/^PROGS/ s/cmoshdtype//' \
		| sed 's/mv /cp /' \
		> src/Makefile || exit 1

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g all || exit 1
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/man/man8 || exit 1
	mkdir -p ${INSTTEMP}/usr/sbin || exit 1
	make DESTROOT=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	exit 1
	;;
esac
