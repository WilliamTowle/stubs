#!/bin/sh
# 21/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	2.0.40)
		sed 's%dev/tty%dev/stdin%' scripts/Configure > scripts/Configure.auto || exit 1
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^HOSTCC/	s%gcc%'${FR_HOST_CC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$$//'`'" ; fi)% ; /^	/ s%scripts/Configure%scripts/Configure.auto% ' \
			> Makefile || exit 1
	;;
	2.4.34*)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^HOSTCC/	s%gcc%'${FR_HOST_CC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$$//'`'" ; fi)% ' \
			> Makefile || exit 1
	;;
	2.6.20*)
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^HOSTCC/	s%gcc%'${FR_HOST_CC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$$//'`'" ; fi)% ' \
			> Makefile || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	case ${PHASE} in
	th)
		yes '' | make ARCH=${TARGET_CPU} oldconfig || exit 1
		mkdir -p ${FR_TC_ROOT}/etc || exit 1
		cp .config ${FR_TC_ROOT}/etc/linux-${PKGVER}-config || exit 1
	;;
	dc)
		cp ${FR_TC_ROOT}/etc/linux-${PKGVER}-config .config || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_LIBCDIR}/src/linux-${PKGVER}
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	PHASE=th do_configure || exit 1

# BUILD...
	make dep || exit 1

# INSTALL...
	mkdir -p ${FR_LIBCDIR}/include
	( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )

	# uClibc 0.9.20/26/28 needs the kernel Makefile
	mkdir -p ${FR_KERNSRC}
	( cd ${FR_KERNSRC}/.. >/dev/null && ln -sf linux-${PKGVER} linux ) || exit 1
	tar cvf - ./ | ( cd ${FR_KERNSRC} >/dev/null && tar xvf - )
}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_LIBCDIR}/src/linux-${PKGVER}
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
	make dep || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/include || exit 1
	( cd include >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${INSTTEMP}/usr/include/ && tar xf - )

#	mkdir -p ${INSTTEMP}/usr/src/linux-${PKGVER} || exit 1
#	( cd ${INSTTEMP}/usr/src >/dev/null && ln -sf linux-${PKGVER} linux ) || exit 1
#	tar cvf - ./ | ( cd ${INSTTEMP}/usr/src/linux && tar xvf - )
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Bad COMMAND $1" 1>&2
	exit 1
;;
esac
