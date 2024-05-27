#!/bin/sh
# 20/01/2007

# (31/07/2006) problems linking with ncurses?

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
#	  CC=${FR_CROSS_CC} \
#	  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
#	  HOSTCC=${FR_HOST_CC} \
#	  ac_cv_func_nanosleep=no \
#		./configure --prefix=/usr \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-nls --disable-largefile \
#		  --with-build-cc=${FR_HOST_CC} \
#		  --with-build-cflags='' --with-build-ldflags='' \
#		  --with-build-libs='' \
#		  --without-ada --without-debug --without-cxx-binding \
#		  || exit 1

	case ${PKGVER}-${PKGREV} in
#	5.5-*)
#		CC=${FR_CROSS_CC} \
#		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
#		  ac_cv_func_nanosleep=no \
#		  ac_cv_func_setvbuf_reversed=no \
#		  CFLAGS=-O2 \
#			./configure \
#			  --prefix=/usr \
#			  --host=`uname -m` --build=${TARGET_CPU} \
#			  --with-build-cc=${FR_HOST_CC} \
#			  --with-build-cflags='' --with-build-ldflags='' \
#			  --with-build-libs='' \
#			  --without-ada --without-debug --without-cxx-binding \
#			  --disable-largefile --disable-nls \
#			  || exit 1
#	;;
	5.6-*)
		CC=${FR_CROSS_CC} \
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
		  ac_cv_func_nanosleep=no \
		  ac_cv_func_setvbuf_reversed=no \
		  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --with-build-cc=${FR_HOST_CC} \
			  --with-build-cflags='' --with-build-ldflags='' \
			  --with-build-libs='' \
			  --without-ada --without-debug --without-cxx-binding \
			  --disable-largefile --disable-nls \
			  --without-gpm \
			  || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^CFLAGS/ s/ -g / /' \
#			> ${MF} || exit 1
#	done
}

do_install()
{
## ...also: data, form, libs, menu, progs?
#	case ${PHASE} in
#	dc)
#		make DESTDIR=${INSTTEMP} install.includes || exit 1
#		make DESTDIR=${INSTTEMP} install.ncurses || exit 1
#		make DESTDIR=${INSTTEMP} install.man || exit 1
#		;;
#	tc)
#		make prefix=${FR_LIBCDIR} install.includes || exit 1
#		make prefix=${FR_LIBCDIR} install.ncurses || exit 1
#		;;
#	esac

	case ${PKGVER} in
	5.6)
		[ -r  misc/run_tic.sh.OLD ] || mv misc/run_tic.sh misc/run_tic.sh.OLD || exit 1
		cat misc/run_tic.sh.OLD \
			| sed 's%LIB tic%LIB ../progs/tic%' \
			> misc/run_tic.sh || exit 1

		( cd progs ; rm tic ; make CC=${FR_HOST_CC} tic ) || exit 1
	;;
	*)
		echo "$0: do_install(): Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	case ${PHASE} in
	dc)
#		make DESTDIR=${INSTTEMP} install.data || exit 1
		make DESTDIR=${INSTTEMP} install.libs || exit 1
		make DESTDIR=${INSTTEMP} install.data || exit 1
	;;
	tc)
		make prefix=${FR_LIBCDIR} install.libs || exit 1
		make prefix=${FR_LIBCDIR} install.data || exit 1
	;;
	esac
}

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

	do_configure || exit 1

# BUILD...
#	make -C include sources || exit 1
#	make -C ncurses CC=${FR_HOST_CC} make_keys make_hash || exit 1
#	make -C progs transform.h || exit 1
#
#		make -C progs all || exit 1
	make all || exit 1

# INSTALL...
	PHASE=dc do_install
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

	do_configure || exit 1

# BUILD...
	make -C include sources || exit 1
	make -C ncurses CC=${FR_HOST_CC} make_keys make_hash || exit 1
	make -C progs transform.h || exit 1

	make -C progs all || exit 1

# INSTALL...
	PHASE=tc do_install
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
