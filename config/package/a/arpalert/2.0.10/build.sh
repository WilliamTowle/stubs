#!/bin/sh
# 26/11/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/pcap.h ] ; then
		echo "$0: Confused -- pcap.h not found - build libpcap?" 1>&2
		exit 1
	fi

	[ "${PKGVER}" == '0.4.15-1' ] && chmod a+x configure
	[ "${PKGVER}" == '0.4.15-2' ] && chmod a+x configure

	  CC=${FR_CROSS_CC} \
		./configure --prefix=/ --includedir=/usr/include --mandir=/usr/share/man \
		  --host=`uname -m` --build=${FR_HOST_DEFN} \
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
	1.1.0|2.0.[01249]|2.0.10)
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
