#!/bin/sh
# 02/10/2004

#TODO:- (...5.x?) runtime requires libncurses.so.5 :(
#TODO:- v6.* configure refuses forced configuration for mbstate_t

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

	case ${PKGVER} in
	5.*)
	# ...we give RANLIB_FOR_TARGET a full path since v5.3 has an
	# errant `ranlib` invocation in `make install`
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
		  CC=${FR_CROSS_CC} \
		  CXX=`echo ${FR_CROSS_CC} | sed 's/gcc$/g++/'` \
		  RANLIB_FOR_TARGET=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin/${TARGET_CPU}-uclibc-ranlib \
		  RANLIB=ranlib \
			./configure --prefix=/usr/local \
			  --host=`uname -m`-pc-linux-gnu --build=${TARGET_CPU}-linux \
			  --disable-largefile --disable-nls \
			  || exit 1
		;;
	6.*)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  bash_cv_have_mbstate_t=no \
		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
		  CC=${FR_CROSS_CC} \
		  CXX=`echo ${FR_CROSS_CC} | sed 's/gcc$/g++/'` \
		  RANLIB=ranlib \
			./configure --prefix=/usr/local \
			  --host=`uname -m`-pc-linux-gnu --build=${TARGET_CPU}-linux \
			  --disable-largefile --disable-nls \
			  --without-curses \
			  || exit 1
		;;
	esac \
		|| exit 1

	case ${PKGVER} in
	5.*)
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/ -g / /' \
				| sed '/^CXXFLAGS/ s/ -g / /' \
				| sed '/^DESTDIR/ s%=.*%= '${INSTTEMP}'%' \
				| sed 's/ $(infodir)/ $(DESTDIR)$(infodir)/' \
				| sed 's/ $(libdir)/ $(DESTDIR)$(libdir)/g' \
				> ${MF} || exit 1
		done || exit 1
		;;
	6.*)
# | sed '/^DEFS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CFLAGS/ s/ -g / /' \
				| sed '/^CXXFLAGS/ s/ -g / /' \
				> ${MF} || exit 1
		done || exit 1
		;;
	esac \
		|| exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make all || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
