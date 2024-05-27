#!/bin/sh
# 19/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -r /lib/libc-2.4.so ] ; then
		# Ubuntu. Assume C++ compiler won't build.
		HOSTCC_LANG_OPTS=--enable-languages=c
	else
		HOSTCC_LANG_OPTS=--enable-languages=c,c++
	fi

	case ${PHASE} in
	th)
#	( cd ${EXTTEMP}/gcc-${PKGVER} || exit 1
#		for PF in ../gcc*patch ; do patch -Np1 -i ${PF} ; done \
#	) || exit 1
		case `basename ${SHELL}`-${BASH_VERSION} in
		bash-3.00.0*)	# 3.00.0(1)-release, SuSE 9.2
			# use idential host/build/target, as not cross compiling.
		# (26/03/2005) ensure cmp,diff PATHed
		PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
			  CC=${FR_HOST_CC} \
				ash ./gcc-${PKGVER}/configure --prefix=${FR_TH_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --build=${FR_HOST_DEFN} \
				  --target=${FR_HOST_DEFN} \
				  --with-local-prefix=${FR_TH_ROOT}/usr \
				  --enable-shared \
				  ${HOSTCC_LANG_OPTS} \
				  --disable-largefile --disable-nls \
				  || exit 1
		;;
		*)
			# use idential host/build/target, as not cross compiling.
			# (26/03/2005) ensure cmp,diff PATHed
		PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
			  CC=${FR_HOST_CC} \
				./gcc-${PKGVER}/configure \
				  --prefix=${FR_TH_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --build=${FR_HOST_DEFN} \
				  --target=${FR_HOST_DEFN} \
				  --with-local-prefix=${FR_TH_ROOT}/usr \
				  ${HOSTCC_LANG_OPTS} \
				  --enable-shared \
				  --disable-largefile --disable-nls \
				  || exit 1
		;;
		esac
	;;
	dc)
# --with-headers and --with-libs specify dirs to copy FROM
#	( cd ${EXTTEMP}/gcc-${PKGVER} || exit 1
#		for PF in ../gcc*patch ; do patch -Np1 -i ${PF} ; done \
#	) || exit 1
		CC=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc \
		  CC_FOR_BUILD=${FR_HOST_CC} \
		  HOSTCC=${FR_HOST_CC} \
		  GCC_FOR_TARGET=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-gcc \
	  	  AR=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-ar \
	  	  AS=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-as \
	  	  LD=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-ld \
	  	  NM=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-nm \
	  	  RANLIB=${FR_TC_ROOT}/usr/bin/${FR_TARGET_DEFN}-ranlib \
	    	  CFLAGS=-O2 \
			./gcc-${PKGVER}/configure -v \
			  --prefix=${INSTTEMP}/usr \
			  --host=`echo ${FR_HOST_DEFN} | sed 's/-gnulibc1//'` \
			  --build=${FR_TARGET_DEFN} \
			  --target=${FR_TARGET_DEFN} \
			  --disable-multilib \
			  --with-headers=${INSTTEMP}/usr/${FR_TARGET_DEFN}/include \
			  --with-libs=${INSTTEMP}/usr/${FR_TARGET_DEFN}/lib \
			  --program-transform-cross-name='s,x,x,' \
			  --with-sysroot=/ \
			  --with-build-sysroot=/ \
			  --enable-languages=c \
			  --enable-shared \
			  --with-gnu-as \
			  --with-gnu-ld \
			  --disable-largefile --disable-nls \
			  || exit 1
		find ./ -name Makefile | while read MF ; do \
			echo ${MF} ;\
			mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed	' /LANGUAGES=/	s/ c++// ; /^gcc_tooldir/ s%..target_alias.%% ; /^SYSTEM_HEADER_DIR/ s%..tooldir./sys%/usr/% ; /INSTALL_DATA.*info/	s/;/; true;/' \
				> ${MF} || exit 1
			done
	;;
	*)
		echo "$0: do_configure(): Unexpected PHASE ${PHASE}" 1>&2
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
		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	if [ -r gcc-2.95.3-2.patch ] ; then
		( cd gcc-${PKGVER} && patch -Np1 -i ../gcc-2.95.3-2.patch || exit 1 )
	fi

	#(05/11/2006) Fix 'configure.in' so we don't get problems
	# with missing directories leading to bad installs
	[ -r gcc-${PKGVER}/configure.in.OLD ] || mv gcc-${PKGVER}/configure.in gcc-${PKGVER}/configure.in.OLD || exit 1
	cat gcc-${PKGVER}/configure.in.OLD \
		| sed '/ tar .* tar / s/; tar/ \&\& tar/g' \
		> gcc-${PKGVER}/configure.in || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	# (02/09/2006) PATH requires binutils
	PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
		make all-gcc prefix=/usr || exit 1

# INSTALL...
	make install prefix=${INSTTEMP}/usr || exit 1
	cat gcc/specs \
		| sed	'	s/ld-linux.so.2/ld-uClibc.so.0/ ; /cross_compile/,+2 s/1/0/ ' > ${INSTTEMP}/usr/lib/gcc-lib/${FR_TARGET_DEFN}/${PKGVER}/specs || exit 1
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

	if [ -r gcc-2.95.3-2.patch ] ; then
		( cd gcc-${PKGVER} && patch -Np1 -i ../gcc-2.95.3-2.patch || exit 1 )
	fi

	#(05/11/2006) Fix 'configure.in' so we don't get problems
	# with missing directories leading to bad installs
	[ -r gcc-${PKGVER}/configure.in.OLD ] || mv gcc-${PKGVER}/configure.in gcc-${PKGVER}/configure.in.OLD || exit 1
	cat gcc-${PKGVER}/configure.in.OLD \
		| sed '/ tar .* tar / s/; tar/ \&\& tar/g' \
		> gcc-${PKGVER}/configure.in || exit 1

	PHASE=th do_configure

# BUILD...
	# (26/03/2005) ensure cmp,diff,tail PATHed
	PATH=${FR_TC_ROOT}/usr/bin:${FR_TH_ROOT}/usr/bin:${PATH} \
		make bootstrap || exit 1

# INSTALL...
	make install || exit 1

	find ${TCTREE}/host-utils -name `uname -m`*gnulibc1*gcc \
		| while read NAME ; do
			mv ${NAME} `echo ${NAME} | sed 's/-gnulibc1//'`
		done
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
