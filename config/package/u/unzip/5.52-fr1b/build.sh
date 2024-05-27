#!/bin/sh -x
# 22/01/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make -f unix/Makefile CC=${FR_CROSS_CC} generic || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/man/man1 || exit 1

	for FILE in unzip funzip unzipsfx ; do \
		cp ${FILE} ${INSTTEMP}/usr/bin/ || exit 1 ;\
	done
	cp man/*.1 ${INSTTEMP}/usr/man/man1/ || exit 1
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi


# BUILD...
	make -f unix/Makefile CC=${FR_HOST_CC} generic || exit 1

# INSTALL...
	mkdir -p ${FR_TH_ROOT}/usr/bin || exit 1
	mkdir -p ${FR_TH_ROOT}/usr/man/man1 || exit 1

	for FILE in unzip funzip unzipsfx ; do \
		cp ${FILE} ${FR_TH_ROOT}/usr/bin/ || exit 1 ;\
	done
	cp man/*.1 ${FR_TH_ROOT}/usr/man/man1/ || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
