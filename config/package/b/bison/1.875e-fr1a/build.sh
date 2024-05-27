#!/bin/sh
# 05/12/2005

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
		[ -r yacc ] && rm yacc
		grep '^#yacc#.' $0 \
			| sed '/exec/ s%/usr%'${INSTROOT}/usr'%' \
			| sed 's/^[^	 ]*.//' > yacc || exit 1
		chmod a+rx yacc || exit 1
	) || exit 1
}

make_dc()
{
# CONFIGURE...
	# sanitc 27/06/2005+
	if [ -d ${INSTTEMP}/host-utils ] ; then
		FR_TH_ROOT=${INSTTEMP}/host-utils
	else
		FR_TH_ROOT=${INSTTEMP}
	fi

	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi

	# (09/08/2005) PATH to (f)lex...
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
	  CFLAGS=-O2 \
		./configure --prefix=/usr \
		 --host=`uname -m` --build=${TARGET_CPU} \
		 || exit 1

# BUILD...
	# (09/08/2005) PATH to (f)lex...
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make || exit 1

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
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	# (09/08/2005) PATH to (f)lex...
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
	  CC=${FR_HOST_CC} \
	  CFLAGS='-O2' \
		./configure --prefix=${FR_TH_ROOT}/usr \
		  --build=`uname -m` \
		  --includedir=/usr/include \
		  || exit 1

	if [ -r /lib/ld-linux.so.1 ] ; then
		for MF in `find ./ -name Makefile` ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^LDFLAGS/ s/=/= -nostdinc /' \
				> ${MF} || exit 1
		done
	fi

# BUILD...
	# (09/08/2005) PATH to (f)lex and m4:
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
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
	exit 1
	;;
esac

#yacc#	#!/bin/sh
#yacc#	 # Begin /usr/bin/yacc
#yacc#	
#yacc#	 exec /usr/bin/bison -y "$@"
#yacc#	
#yacc#	 # End /usr/bin/yacc
