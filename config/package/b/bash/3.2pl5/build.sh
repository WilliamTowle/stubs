# 14/10/2006
# 03/12/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in ${PKGNAME}*-00? ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np0 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

	case ${PHASE} in
	dc)
#		   bash_cv_have_mbstate_t=yes
		 CC=${FR_CROSS_CC} \
		   ac_cv_func_setvbuf_reversed=no \
		   CC_FOR_BUILD=${FR_HOST_CC} \
		   CFLAGS=-O2 \
			./configure --prefix=/usr --bindir=/bin \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  --enable-alias --with-curses \
			  --without-bash-malloc \
			  || exit 1
	;;
	th)
	# (21/05/2004) ...try to be *really* minimal for the toolchain version
# ac_cv_header_wchar_h=no \
		CC=${FR_HOST_CC} \
			./configure --prefix=${FR_TH_ROOT}/usr --bindir=${FR_TH_ROOT}/bin \
			  --enable-alias \
			  --disable-readline \
			  --without-curses \
			  --without-bash-malloc \
			  || exit 1
	;;
	*)
		echo "$0: do_configure: Unexpected PHASE ${PHASE}" 1>&2
		exit 1
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

	case ${PKGVER} in
	3.1)
		if [ -d ${PKGNAME}-${PKGVER} ] ; then
			for PF in *patch ; do
				cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
			done
			cd ${PKGNAME}-${PKGVER} || exit 1
		fi
	;;
	esac

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	PHASE=dc do_configure || exit 1

# BUILD...

	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	( cd ${INSTTEMP}/bin && ln -sf bash sh ) || exit 1
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

#	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
#	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.6.4 and prior
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi

	case ${PKGVER} in
	3.1)
		if [ -d ${PKGNAME}-${PKGVER} ] ; then
			for PF in *patch ; do
				cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
			done
			cd ${PKGNAME}-${PKGVER} || exit 1
		fi
	;;
	esac

	PHASE=th do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
	( cd ${FR_TH_ROOT}/bin && ln -sf bash sh )
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
