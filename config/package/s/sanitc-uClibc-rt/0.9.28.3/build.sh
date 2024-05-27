#!/bin/sh
# 2007-08-04

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d uClibc-${PKGVER} ] ; then
		find patch/. -name *patch | while read PF ; do
			patch --batch -d uClibc-${PKGVER} -Np1 < ${PF} || exit 1
		done
		cd uClibc-${PKGVER}
	fi || exit 1

	cp ${TCTREE}/etc/${USE_TOOLCHAIN}/uClibc-${PKGVER}-config .config
	yes '' | make HOSTCC=${FR_HOST_CC} oldconfig \
		  || exit 1
}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
	make || exit 1
	rm -f utils/*.o
	make CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
		HOSTCC=${FR_CROSS_CC} \
		-C utils --always-make ldconfig || exit 1

## INSTALL...
	make PREFIX=${INSTTEMP} RUNTIME_PREFIX=/ install_runtime || exit 1
	mkdir -p ${INSTTEMP}/sbin || exit 1
	cp utils/ldconfig ${INSTTEMP}/sbin || exit 1
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
