#!/bin/sh
# 07/12/2005

# TODO:- Note the SUBDIRS setting - we don't (can't?) make everything
# TODO:- netkit-rsh fails over vfork()

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

		./configure \
		  --prefix=/usr --installroot=${INSTTEMP} \
		  --without-pam --without-readline \
		  || exit 1

	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's/-o root/${UIDOPTS}/' \
			| sed 's/-g root/${GIDOPTS}/' \
			| sed 's% $(MANDIR)% $(INSTALLROOT)/$(MANDIR)%' \
			> ${MF} || exit 1
	done

# BUILD...

# NB:- no netkit-ntalk, bsd-finger, linux-ftpd, netwrite,
# NB: netkit-bootparamd, netkit-rusers, netkit-rwall, netkit-timed
	SUBDIRS="netkit-base netkit-rpc \
		netkit-tftp \
		biff+comsat netkit-rwho \
		netkit-routed"
#	SUBDIRS="netkit-base netkit-rpc \
#		netkit-ntalk bsd-finger linux-ftpd netkit-ftp netwrite \
#		netkit-bootparamd netkit-tftp \
#		biff+comsat netkit-rusers netkit-rwho netkit-rwall \
#		netkit-routed netkit-rsh netkit-telnet netkit-timed"
#			 CFLAGS='-nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include' \
#			 CXXFLAGS='-nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include' \

	for SUB in ${SUBDIRS} ; do
			make -C ${SUB} \
			 CC=${FR_CROSS_CC} CXX=`echo ${FR_CROSS_CC} | sed 's/gcc$/g++/'` \
			 || exit 1
	done

# INSTALL...
	mkdir -p ${INSTTEMP}/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/bin ${INSTTEMP}/usr/sbin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 ${INSTTEMP}/usr/man/man5 ${INSTTEMP}/usr/man/man8 || exit 1

	for SUB in ${SUBDIRS} ; do
		make -C ${SUB} prefix=${INSTTEMP}/usr install || exit 1
	done
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
