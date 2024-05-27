#!/bin/sh
# 01/03/2006

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

	# without-included-regex here, as uClibc conflicts
	# PATH needs autoconf >= 2.58
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr --bindir=/bin \
		  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
		  --disable-largefile --disable-nls \
		  --without-included-regex \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
#	find ${INSTTEMP} -type f > tmp.find.$$ || exit 1
#	cat tmp.find.$$ | while read FILE ; do \
#		cp ${FILE} tmp.$$ || exit 1
#		sed "s%${TCTREE}%%g" tmp.$$ > ${FILE} || exit 1
#	done
#	rm tmp.find.$$
#	( cd ${INSTTEMP}/usr/bin && ( \
#		for F in *-* ; do \
#			ln -sf ${F} `echo ${F} | sed 's/-.*//'` ;\
#		done \
#	) || exit 1 ) || exit 1
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
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	# without-included-regex here, as uClibc conflicts
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=${FR_TH_ROOT}/usr --bindir=${FR_TH_ROOT}/bin \
		  --host=`uname -m` --build=${TARGET_CPU}-uclibc-linux \
		  --disable-largefile --disable-nls \
		  --without-included-regex \
		  || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make DESTDIR='' install || exit 1
	( cd ${FR_TH_ROOT}/usr/share || exit 1
		case ${PKGVER} in
		1.9.?)
			ln -sf automake-`echo ${PKGVER} | sed 's/..$//'` automake || exit 1
		;;
		1.10)
			ln -sf automake-${PKGVER} automake || exit 1
		;;
		*)
			echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
			exit 1
		;;
		esac
	) || exit 1
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
