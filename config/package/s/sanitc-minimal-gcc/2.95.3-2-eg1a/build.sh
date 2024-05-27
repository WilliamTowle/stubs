#!/bin/sh
# 21/05/2007

#TODO:- correct determination of FR_HOST_CC
#TODO:- whether configure needs 'bfd_cv_has_long_long=yes'?

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

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

	#(05/11/2006) abort installs if source OR target missing (otherwise
	# the "Copying no" phase transfers the source tree by mistake)
	[ -r gcc-${PKGVER}/configure.in.OLD ] || mv gcc-${PKGVER}/configure.in gcc-${PKGVER}/configure.in.OLD || exit 1
	cat gcc-${PKGVER}/configure.in.OLD \
		| sed '/ tar .* tar / s/; tar/ \&\& tar/g' \
		> gcc-${PKGVER}/configure.in || exit 1

	case `basename ${SHELL}`-${BASH_VERSION} in
	bash-3.00.0*)	# 3.00.0(1)-release, SuSE 9.2
		# configure '--with-newlib' to build as little as possible
		# (26/03/2005) configure needs diffutils PATHed
	PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
		  ac_cv_path_install=`which install` \
		  CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			ash ./gcc-${PKGVER}/configure -v \
			  --prefix=${FR_TC_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --build=${FR_HOST_DEFN} \
				  --target=`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/ ; s/-uclibc$/-linux/'` \
			  --enable-languages=c \
			  --enable-shared \
			  --without-headers \
			  --with-newlib \
			  --disable-largefile --disable-nls \
			  || exit 1
#			  --with-local-prefix=${FR_TC_ROOT}/usr \
	;;
	*)
		# configure '--with-newlib' to build as little as possible
		# (26/03/2005) configure needs diffutils PATHed
	PATH=${FR_TC_ROOT}/usr/bin:${PATH} \
		  ac_cv_path_install=`which install` \
		  CC=${FR_HOST_CC} \
		  CFLAGS=-O2 \
			./gcc-${PKGVER}/configure -v \
			  --prefix=${FR_TC_ROOT}/usr \
				  --host=${FR_HOST_DEFN} \
				  --build=${FR_HOST_DEFN} \
				  --target=`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/ ; s/-uclibc$/-linux/'` \
			  --enable-languages=c \
			  --enable-shared \
			  --without-headers \
			  --with-newlib \
			  --disable-largefile --disable-nls \
			  || exit 1
#			  --with-local-prefix=${FR_TC_ROOT}/usr \
	;;
	esac

# BUILD...
	# make sure only to make 'all-gcc' for the proto-compiler:
	# (26/03/2005) build needs diffutils and flex PATHed
	# (02/09/2006) PATH requires binutils
	PATH=${FR_TC_ROOT}/usr/bin:${FR_TH_ROOT}/usr/bin:${PATH} \
		make all-gcc || exit 1

# INSTALL...
	# since we're only building the compiler:
	make install-gcc || exit 1

	# ...preserve an assembler for kernel builds:
#	( cd ${FR_TC_ROOT}/usr/bin || exit 1
	for EXE in addr2line ar as \
		c++filt ld nm objcopy objdump \
		ranlib readelf size strings strip ; do

		( cd ${FR_TC_ROOT}/usr/bin && ln -sf ${FR_TARGET_DEFN}-${EXE} `echo ${FR_TARGET_DEFN}-${EXE} | sed 's/-[^-]*-/-kernel-/'` ) || exit 1
		mkdir -p ${FR_TC_ROOT}/usr/`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`/bin
		( cd ${FR_TC_ROOT}/usr/`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`/bin && ln -sf ../../${FR_TARGET_DEFN}/bin/${EXE} ./ ) || exit 1
	done
	true
}

case "$1" in
#distro-cross)
#	make_dc || exit 1
#;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
