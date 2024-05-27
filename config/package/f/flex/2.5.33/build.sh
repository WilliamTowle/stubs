#!/bin/sh
# 07/03/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_install()
{
	case ${PHASE} in
	dc)
		DESTDIR=${INSTTEMP}
		INSTPATH=${INSTTEMP}
		INSTROOT=''
	;;
	th)
		DESTDIR=''
		INSTPATH=${FR_TH_ROOT}
		INSTROOT=${FR_TH_ROOT}
	;;
	*)
		echo "$0: do_post_install(): Unexpected PHASE ${PHASE}" 1>&2
		exit 1
	;;
	esac

	#make DESTDIR='' includedir=${INSTTEMP}/usr/include
	DESTDIR=${DESTDIR} make install || exit 1

	( cd ${INSTPATH}/usr/bin || exit 1
		[ -r lex ] && rm lex
		grep '^#lex#.' $0 \
			| sed '/exec/ s%/usr%'${INSTROOT}/usr'%' \
			| sed 's/^[^	 ]*.//' > lex || exit 1
		chmod a+rx lex || exit 1
	) || exit 1
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

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_CROSS_CC} \
	  CFLAGS='-O2' \
		./configure \
		  --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls \
		  || exit 1

# | sed '/^AR *=/ s%=.*%= '`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'`'%' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^AM_CPPFLAGS *=/ s%-I${prefix}/include%%' \
			| sed '/^oldincludedir *=/ s/^/#/' \
			> ${MF} || exit 1
	done

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make all \
		 || exit 1

# INSTALL...
	PHASE=dc do_install
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

	CC=${FR_HOST_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=${FR_TH_ROOT}/usr \
		  || exit 1
#		  --includedir=${FR_TH_ROOT}/include \
#		  --localstatedir=${FR_TH_ROOT}/var \

	find ./ -name [Mm]akefile | while read MF ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^	.*--info-dir/	s/install-info/true/' \
			> ${MF} || exit 1
#			| sed '/^	/	s/install-info /install-info --backup=none /' \
	done

# BUILD...
	make || exit 1

# INSTALL...
	PHASE=th do_install
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

#lex#	#!/bin/sh
#lex#	# Begin /usr/bin/lex
#lex#	
#lex#	exec /usr/bin/flex -l "$@"
#lex#	
#lex#	# End /usr/bin/lex
