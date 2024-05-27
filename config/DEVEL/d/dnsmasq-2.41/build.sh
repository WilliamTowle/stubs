#!/bin/sh -x
# 2007-08-31

# (20/04/2006) HAVE_LINUX_NETWORK fails - no capability.h
# (20/04/2006) 'undef HAVE_LINUX_NETWORK' fails - no BSD includes
# (19/10/2006) forward.c parse error?  (union member 'control')

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	2.20) ;;
	2.25|2.27)
		[ -r src/config.h.OLD ] || mv src/config.h src/config.h.OLD || exit 1
		cat src/config.h.OLD \
			| sed '/define HAVE_RTNETLINK/	s%$%/* changed */%' \
			| sed '/define HAVE_RTNETLINK/	s/define/undef/' \
			> src/config.h || exit 1
	;;
#	# 2.28, 2.29, 2.30, 2.31 dubious for 2.0.x kernels
#	2.3[23456])
#		[ -r src/config.h.OLD ] || mv src/config.h src/config.h.OLD || exit 1
#		cat src/config.h.OLD \
#			| sed	' /define HAVE_LINUX_NETWORK/	s%$%/* changed */%
#				; /define HAVE_LINUX_NETWORK/	s/define/undef/ 
#				; /undef HAVE_LINUX_NETWORK/	s%$%\n#define IP_SENDSRCADDR\n%
#				; /undef HAVE_LINUX_NETWORK/	s%$%\n#define IP_RECVDSTADDR\n%
#				' > src/config.h || exit 1
#
#		[ -r src/dnsmasq.h.OLD ] || mv src/dnsmasq.h src/dnsmasq.h.OLD || exit 1
#		cat src/dnsmasq.h.OLD \
#			| sed	' /net.if_dl.h/	s%^%/* %
#				; /net.if_dl.h/	s%$% */%
#				' > src/dnsmasq.h || exit 1
#		# PROBLEM: forward.c union members
#
###		[ -r src/dnsmasq.h.OLD ] || mv src/dnsmasq.h src/dnsmasq.h.OLD || exit 1
###		cat src/dnsmasq.h.OLD \
###			| sed	' /linux.capability.h/	s%^%/* %
###				; /linux.capability.h/	s%$% */%
###				; /sys.prctl.h/	s%^%/* %
###				; /sys.prctl.h/	s%$% */%
###				' > src/dnsmasq.h || exit 1
#	;;
	# 2.28, 2.29, 2.30, 2.31 dubious for 2.0.x kernels
	2.4[01])
		[ -r src/config.h.OLD ] || mv src/config.h src/config.h.OLD || exit 1
		cat src/config.h.OLD \
			| sed	's%defined(__UCLIBC__)%1 /* earlgrey */%' \
			| sed	'/define HAVE_LINUX_NETWORK/ { s%$%/* changed */% ; s/define/undef/ }' \
			> src/config.h || exit 1
#				; /define HAVE_LINUX_NETWORK/	s/define/undef/ 
#				; /undef HAVE_LINUX_NETWORK/	s%$%\n#define IP_SENDSRCADDR\n%
#				; /undef HAVE_LINUX_NETWORK/	s%$%\n#define IP_RECVDSTADDR\n%
#				' > src/config.h || exit 1

		[ -r src/dnsmasq.h.OLD ] || mv src/dnsmasq.h src/dnsmasq.h.OLD || exit 1
		cat src/dnsmasq.h.OLD \
			| sed	' s/ filename\[\];/* filename;/
				; /net.if_dl.h/	{ s%^%/* % ; s%$% */% }
				' > src/dnsmasq.h || exit 1


##		# PROBLEM: forward.c union members
##
#####		[ -r src/dnsmasq.h.OLD ] || mv src/dnsmasq.h src/dnsmasq.h.OLD || exit 1
#####		cat src/dnsmasq.h.OLD \
#####			| sed	' /linux.capability.h/	s%^%/* %
#####				; /linux.capability.h/	s%$% */%
#####				; /sys.prctl.h/	s%^%/* %
#####				; /sys.prctl.h/	s%$% */%
#####				' > src/dnsmasq.h || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	do_configure

# BUILD...
	make CC=${FR_CROSS_CC} \
		  all || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
