#!/bin/sh
# 2007-08-16

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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
	1.0.0)
		  ac_cv_linux_vers=`ls -l ${FR_KERNSRC} | sed 's/.*-//'` \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
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
	1.0.0)
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
	0.9.[457]|1.0.0)
		make DESTDIR=${INSTTEMP} install || exit 1
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
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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
	1.0.0)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		  ac_cv_linux_vers=`ls -l ${FR_KERNSRC} | sed 's/.*-//'` \
		  CC=${FR_CROSS_CC} \
			./configure --prefix=${FR_LIBCDIR} \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
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
#	# Needs path to '[f]lex' (19/07/2005)
#	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
#		make || exit 1
	1.0.0)
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
	0.9.[457]|1.0.0)
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
