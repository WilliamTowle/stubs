#!/bin/sh -x
# 26/03/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	KGCC_TRANSFORM='s/-[a-z]*-/-kernel-/'
	KGCC_TRIPLET=`echo ${FR_TARGET_DEFN} | sed ${KGCC_TRANSFORM}`

	if [ -d uclibc ] ; then
		echo "...Patching [Gentoo]..."
		for PF in uclibc/*patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
	elif [ ${PKGVER} = '4.1.2' ] ; then
		echo "...Patching [LFS]..."
		for PF in *patch ; do
			patch --batch -d gcc-${PKGVER} -Np1 < ${PF} || exit 1
		done
	fi

	CC=${FR_HOST_CC} \
		./gcc-${PKGVER}/configure -v \
		  --prefix=${FR_TC_ROOT}/usr \
		  --host=${FR_HOST_DEFN} \
		  --build=${FR_HOST_DEFN} \
			  --target=${FR_TARGET_DEFN} \
			  --program-prefix=${KGCC_TRIPLET}- \
		  --enable-languages=c \
		  --disable-nls \
		  --disable-shared \
		  --disable-threads \
		  --without-headers \
		  --with-gnu-ld \
		  --with-gnu-as \
		  || exit 1
#		  --program-transform-cross-name=${KGCC_TRANSFORM}
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

#	# ...preserve an assembler for kernel builds:
	mkdir -p ${FR_TC_ROOT}/usr/${KGCC_TRIPLET}
	( cd ${FR_TC_ROOT}/usr/${KGCC_TRIPLET} \
		&& ln -sf ../${FR_TARGET_DEFN}/bin ./ \
		&& ln -sf ../${FR_TARGET_DEFN}/lib ./ \
	) || exit 1

	for EXE in addr2line ar as \
		c++filt ld nm objcopy objdump \
		ranlib readelf size strings strip ; do

		( cd ${FR_TC_ROOT}/usr/bin && ln -sf ${FR_TARGET_DEFN}-${EXE} ${KGCC_TRIPLET}-${EXE}) || exit 1
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
