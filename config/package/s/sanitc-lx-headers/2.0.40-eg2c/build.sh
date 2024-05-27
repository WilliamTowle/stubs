#!/bin/sh
# 2008-08-15

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	2.0.40)
		if [ -r ${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-2.7.2.3-gnu-kgcc ] ; then
			FR_KERNEL_CC=${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-2.7.2.3-gnu-kgcc
		else
			# try uClibc's cross-compiler, if we've built it
			FR_KERNEL_CC=${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-gcc
		fi

		sed 's%dev/tty%dev/stdin%' scripts/Configure > scripts/Configure.auto || exit 1
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^ARCH *:=/	s/=.*/= '${TARGET_CPU}'/' \
			| sed	' /^HOSTCC[ 	]*=/	s%gcc%'${FR_HOST_CC}'%' \
			| sed	'/^	/ s%scripts/Configure%scripts/Configure.auto% ' \
			> Makefile || exit 1
# | sed	' /^HOSTCC/	s%gcc%'${FR_HOST_CC}'% ; /[(]CROSS_COMPILE[)]/	s%$$(CROSS_COMPILE)%$$(shell if [ -n "$${CROSS_COMPILE}" ] ; then echo $${CROSS_COMPILE} ; else echo "'`echo ${FR_HOST_CC} | sed 's/gcc$$//'`'" ; fi)% ; /^	/ s%scripts/Configure%scripts/Configure.auto% ' \
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
		yes '' | make oldconfig || exit 1
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
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=th do_configure || exit 1

# BUILD...
	make dep || exit 1

# INSTALL...
	mkdir -p ${FR_LIBCDIR}/include
	( cd include/ >/dev/null && tar cvf - asm asm-${TARGET_CPU} asm-generic linux ) | ( cd ${FR_LIBCDIR}/include/ && tar xf - )

	# uClibc 0.9.20/26/28 needs the kernel Makefile
	mkdir -p ${FR_KERNSRC}-${PKGVER}
	( cd `dirname ${FR_KERNSRC}` && ln -sf linux-${PKGVER} linux ) || exit 1
	tar cvf - ./ | ( cd ${FR_KERNSRC} >/dev/null && tar xvf - )
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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