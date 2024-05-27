#!/bin/sh
# 2007-11-19

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

	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
		exit 1
	fi

	[ "${PKGVER}" == '0.4.15-1' ] && chmod a+x configure
	[ "${PKGVER}" == '0.4.15-2' ] && chmod a+x configure

	  CC=${FR_CROSS_CC} \
		./configure --prefix=/ \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  --with-pcap=`uname -s | tr A-Z a-z` \
		  || exit 1

	case ${PKGVER} in
	# 0.4.14 was buggy
	0.4.15*)
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/-g / /' \
				| sed '/^config_dir/ s/${prefix}//' \
				| sed '/^localstatedir/ s/${prefix}//' \
				| sed '/^leases_dir/ s/${prefix}//' \
				| sed '/^lock_dir/ s/${prefix}//' \
				| sed '/^	/ s/$(config_dir)/${DESTDIR}${config_dir}/g' \
				| sed '/^	/ s/$(leases_dir)/${DESTDIR}${leases_dir}/g' \
				| sed '/^	/ s/$(log_dir)/${DESTDIR}${log_dir}/g' \
				| sed '/^	/ s/$(lock_dir)/${DESTDIR}${lock_dir}/g' \
				| sed '/^	/ s/$(mandir)/${DESTDIR}${mandir}/g' \
				| sed '/^	/ s/$(sbindir)/${DESTDIR}${sbindir}/g' \
				| sed '/^	/ s/$(sysconfdir)/${DESTDIR}${sysconfdir}/g' \
				> ${MF} || exit 1
		done
	;;
	1.1.0|2.0.[01249])
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/-g / /' \
				> ${MF} || exit 1
		done
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...

	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/var/run || exit 1
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
