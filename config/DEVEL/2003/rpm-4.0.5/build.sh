#!/bin/sh
# 02/10/2004

# NB: - Requires uClibc compiled with 'UCLIBC_HAS_RPC=y' and
# NB: 'UCLIBC_HAS_FULL_RPC=y' (v0.9.19-3, NOT 0.9.19-2)

# TODO:- ./configure fails - bad sed substitutions?

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

##	./autogen.sh --noconfigure
##	aclocal
#	PATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin:${PATH} \
#	 CC=${FR_CROSS_CC} \
#	 ac_cv_sizeof_char=1 \
#	 ac_cv_sizeof_unsigned_char=1 \
#	 ac_cv_sizeof_short=2 \
#	 ac_cv_sizeof_unsigned_short=2 \
#	 ac_cv_sizeof_int=4 \
#	 ac_cv_sizeof_unsigned_int=4 \
#	 ac_cv_sizeof_long=4 \
#	 ac_cv_sizeof_unsigned_long=4 \
#	 ac_cv_sizeof_long_long=8 \
#	 ac_cv_sizeof_unsigned_long_long=8 \
#	 ac_cv_sizeof_long_long=8 \
#	 ac_cv_sizeof_unsigned_long_long=8 \
#	 ac_cv_sizeof_float=4 \
#	 ac_cv_sizeof_double=8 \
#	 db_cv_alignp_t="unsigned long long" \
#	 db_cv_mutex=x86/gcc-assembly \
#	 db_cv_fcntl_f_setfd=yes \
#	 db_cv_sprintf_count=yes \
#		./configure --prefix=/usr \
#		 --host=`uname -m` --build=${TARGET_CPU} \
#		 --sysconfdir=/etc --localstatedir=/var \
#		 --enable-shared=beecrypt,db3 \
#		 --with-included-gettext=no \
#		 || exit 1
#	PATH=${FR_LIBCDIR}/bin:${PATH}
	 CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		 --host=`uname -m` --build=${TARGET_CPU} \
		 --sysconfdir=/etc --localstatedir=/var \
		 --enable-shared=beecrypt,db3 \
		 --with-included-gettext=no \
		 || exit 1

#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^DEFS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
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

#	./autogen.sh --noconfigure
#	aclocal
	./configure --prefix=/usr \
		 --sysconfdir=/etc --localstatedir=/var \
		 --enable-shared=beecrypt,db3 --with-included-gettext=no \
		 || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
