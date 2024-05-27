#!/bin/sh
# 08/06/2003

# TODO: - Requires Python.h
# TODO: - Has its build.mak still (keep until above fixed)!

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

#prelim:
#	[ -r autogen.sh.OLD ] || cp autogen.sh autogen.sh.OLD
## autogen.sh mods: 1: libtoolize is version we make
## autogen.sh mods: 2: ensure descend-into-subdir commands work
#	cat autogen.sh.OLD \
#		| sed 's%LTV="libtoolize (GNU libtool) 1.4"%LTV="libtoolize (GNU libtool) 1.4.2"%' \
#		| sed 's%ACV="Autoconf version 2.13"%ACV="autoconf (GNU Autoconf) 2.53"%' \
#		| sed 's%"`autoconf --version`"%"`autoconf --version | head -1`"%' \
#		| sed 's%AMV="automake (GNU automake) 1.4-p5"%AMV="automake (GNU automake) 1.6"%' \
#		| sed 's%; \.% \&\& .%' \
#		> autogen.sh

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
# GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

#	./autogen.sh --noconfigure
#	aclocal
#	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH}
	 CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		 --sysconfdir=/etc --localstatedir=/var \
		 --enable-shared=beecrypt,db3 --with-included-gettext=no

# BUILD...
#	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH}
		make

# INSTALL...
	make DESTDIR=${INSTTEMP} install
#	./configure --prefix=${INSTTEMP}/usr || exit 1
#	make || exit 1
#	make install || exit 1
}

make_toolchain()
{
#	./autogen.sh --noconfigure
#	aclocal
	./configure --prefix=/usr \
		--sysconfdir=/etc --localstatedir=/var \
		--enable-shared=beecrypt,db3 --with-included-gettext=no
	make
	make DESTDIR=${INSTTEMP} install
#	./configure --prefix=${INSTTEMP}/usr || exit 1
#	make || exit 1
#	make install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain)
	INSTTEMP=${TCTREE} make_toolchain || exit 1
	;;
*)
	exit 1
	;;
esac
