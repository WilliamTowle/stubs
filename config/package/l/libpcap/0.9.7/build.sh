#!/bin/sh
# 2007-08-16

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
#	0.8.3)
#		# Needs path to '[f]lex' (19/07/2005)
#		PATH=${FR_LIBCDIR}/bin:${TCTREE}/usr/bin:${PATH} \
#		  ac_cv_linux_vers=`ls -l ${FR_KERNSRC} | sed 's/.*-//'` \
#		  CC=${FR_CROSS_CC} \
#			./configure --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --with-pcap=`uname -s | tr A-Z a-z` \
#			  || exit 1
#
#		# these mods from ver 0.8.3 (0.8.1 previous, 0.8.2 untested)
#		for SF in gencode.c pcap.c savefile.c ; do
#			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
#			cat ${SF}.OLD \
#				| sed '/DLT_IEEE802_11_RADIO_AVS/ s%^%/* %' \
#				| sed '/DLT_IEEE802_11_RADIO_AVS/ s%$% */%' \
#				| sed '/DLT_JUNIPER_MONITOR/ s%^%/* %' \
#				| sed '/DLT_JUNIPER_MONITOR/ s%$% */%' \
#				| sed '/DLT_SYMANTEC_FIREWALL/ s%^%/* %' \
#				| sed '/DLT_SYMANTEC_FIREWALL/ s%$% */%' \
#				> ${SF} || exit 1
#		done
#	;;
	0.9.[457])
#		PATH=${FR_TH_ROOT}/usr/bin:${PATH}
		  ac_cv_linux_vers=`ls -l ${FR_KERNSRC} | sed 's/.*-//'` \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --with-pcap=`uname -s | tr A-Z a-z` \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
#	0.8.3)
#		PATH=${FR_LIBCDIR}/bin:${PATH} \
#			make || exit 1
#	;;
	0.9.[457])
		# Needs path to '[f]lex' (19/07/2005)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			make || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
##	0.8.3)
#		make DESTDIR=${INSTTEMP} \
#			install || exit 1
##	;;
	0.9.[457])
		make DESTDIR=${INSTTEMP} \
			install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
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


	if [ ! -x ${FR_TH_ROOT}/usr/bin/flex -o ! -x ${FR_TH_ROOT}/usr/bin/bison ] ; then
		echo "$0: CONFIGURE: Needs both 'flex' and 'bison'" 1>&2
		exit 1
	fi

	case ${PKGVER} in
#	0.8.3)
#		# Needs path to '[f]lex' (19/07/2005)
#		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
#		  ac_cv_linux_vers=`ls -l ${FR_KERNSRC} | sed 's/.*-//'` \
#		  CC=${FR_CROSS_CC} \
#			./configure --prefix=${FR_LIBCDIR} \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --with-pcap=`uname -s | tr A-Z a-z` \
#			  || exit 1
#
#		# these mods from ver 0.8.3 (0.8.1 previous, 0.8.2 untested)
#		for SF in gencode.c pcap.c savefile.c ; do
#			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
#			cat ${SF}.OLD \
#				| sed '/DLT_IEEE802_11_RADIO_AVS/ s%^%/* %' \
#				| sed '/DLT_IEEE802_11_RADIO_AVS/ s%$% */%' \
#				| sed '/DLT_JUNIPER_MONITOR/ s%^%/* %' \
#				| sed '/DLT_JUNIPER_MONITOR/ s%$% */%' \
#				| sed '/DLT_SYMANTEC_FIREWALL/ s%^%/* %' \
#				| sed '/DLT_SYMANTEC_FIREWALL/ s%$% */%' \
#				> ${SF} || exit 1
#		done
#	;;
	0.9.[457])
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  ac_cv_linux_vers=`ls -l ${FR_KERNSRC} | sed 's/.*-//'` \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=${FR_LIBCDIR} \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --with-pcap=`uname -s | tr A-Z a-z` \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	# Needs path to '[f]lex' (19/07/2005)
	PATH=${FR_TH_ROOT}/usr/bin:${PATH}
		make || exit 1

# INSTALL...
	case ${PKGVER} in
##	0.8.3)
#		make DESTDIR=${INSTTEMP} \
#			install || exit 1
##	;;
	0.9.[457])
		make install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
