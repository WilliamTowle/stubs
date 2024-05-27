#!/bin/sh
# 03/12/2005

# Assembler warnings with freg-0.6.8 (binutils-2.17)
# Fails to find compiler with freg-0.9.2pre1

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

#echo "FIX GCCINCDIR"
#	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#	cat Makefile.OLD \
#		| sed 's/^CC=/#CC/' \
#		| sed '/uclibc-gcc/ s/^.*$/CC=${CCPREFIX}cc/' \
#		| sed 's%_DIR =.*usr%_DIR=${DESTDIR}/usr%' \
#		| sed 's/-o root//' \
#		| sed 's/-g bin//' \
#		| sed '/^INCLUDES/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#		> Makefile || exit 1
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed	' /^CC=/	s%/.*cc%'${FR_CROSS_CC}'%
			; s%_DIR =.*usr%_DIR=${DESTDIR}/usr%
			; s/-o root//
			; s/-g bin//
			' > Makefile || exit 1


# BUILD...
#	# PATH=${UCPATH}/bin:${PATH} \
#	make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
#		|| exit 1
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/include || exit 1
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

#echo "FIX GCCINCDIR"
#	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#	cat Makefile.OLD \
#		| sed 's/^CC=/#CC/' \
#		| sed '/uclibc-gcc/ s/^.*$/CC=${CCPREFIX}cc/' \
#		| sed 's%_DIR =.*usr%_DIR=${DESTDIR}/usr%' \
#		| sed 's/-o root//' \
#		| sed 's/-g bin//' \
#		| sed '/^INCLUDES/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#		> Makefile || exit 1
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed	' /^CC=/	s%/.*cc%'${FR_CROSS_CC}'%
			; s%_DIR =.*usr%_DIR=${DESTDIR}/usr%
			; s/-o root//
			; s/-g bin//
			' > Makefile || exit 1

# BUILD...
#	# PATH=${UCPATH}/bin:${PATH} \
#	make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
#		|| exit 1
	make || exit 1

# INSTALL...
	make DESTDIR=${TCTREE} \
		install || exit 1
	for HEADER in _gl keyboard/vgakeyboard vga ; do
		cp ${HEADER}.h ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/include/ || exit 1
	done || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	exit 1
	;;
esac
