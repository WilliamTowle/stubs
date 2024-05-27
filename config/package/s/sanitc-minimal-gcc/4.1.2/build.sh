#!/bin/sh -x
# 26/03/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d uclibc ] ; then
		echo "...Patching [Gentoo]..."
		for PF in uclibc/*patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
#		cd gcc-${PKGVER}
	else
		echo "...Patching [LFS]..."
		for PF in *patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
	fi

	CC=${FR_HOST_CC} \
		./gcc-${PKGVER}/configure -v \
		  --prefix=${FR_TC_ROOT}/usr \
		  --host=${FR_HOST_DEFN} \
		  --target=`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'` \
		  --enable-languages=c \
		  --disable-nls \
		  --disable-shared \
		  --disable-threads \
		  --without-headers \
		  --with-gnu-ld \
		  --with-gnu-as \
		  || exit 1
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

	PHASE=th do_configure

# BUILD...
	# make sure only to make 'all-gcc' for the proto-compiler:
	# (26/03/2005) build needs diffutils and flex PATHed
	# (02/09/2006) PATH requires binutils
	PATH=${FR_TC_ROOT}/usr/bin:${FR_TH_ROOT}/usr/bin:${PATH} \
		make all-gcc || exit 1

# INSTALL...
	make install-gcc || exit 1
#	for EXE in addr2line ar as c++filt ld nm \
#		objcopy objdump ranlib readelf size \
#		strings strip ; do \
#		( cd ${FR_TC_ROOT}/usr/bin && ln -sf ${FR_TARGET_DEFN}-${EXE} `echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`-${EXE} ) || exit 1 ;\
#		( cd ${FR_TC_ROOT}/usr/`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`/bin && ln -sf ../../${FR_TARGET_DEFN}/bin/${EXE} ./ ) || exit 1 ;\
#	done
	for EXE in addr2line c++filt objcopy readelf size strings ; do
		( cd ${FR_TC_ROOT}/usr/bin && ln -sf ${FR_TARGET_DEFN}-${EXE} `echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`-${EXE} ) || exit 1
		if [ -r ${FR_TC_ROOT}/usr/${FR_TARGET_DEFN}-uclibc/bin/${EXE} ] ; then
			( cd ${FR_TC_ROOT}/usr/`echo ${FR_TARGET_DEFN} | sed 's/-[^-]*-/-kernel-/'`/bin && ln -sf ../../${FR_TARGET_DEFN}-uclibc/bin/${EXE} ./ ) || exit 1
		fi
	done
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
