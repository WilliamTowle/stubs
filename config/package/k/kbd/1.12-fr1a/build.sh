#!/bin/sh
# 18/11/2006

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

	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

	# ...non-standard ./configure, has very few options
	 CC=${FR_CROSS_CC} \
		./configure --prefix=/usr || exit 1

	cat > defines.h <<EOF
#define HAVE_locale_h
#define HAVE_libintl_h
EOF

	echo "ARCH="`echo ${TARGET_CPU} | sed 's/[4-9]86/386/'` \
		> make_include
	echo "HAVE_XGETTEXT=no" >> make_include || exit 1

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
# | sed 's/^CC[ 	]*=.*/CC=${CCPREFIX}cc/' \
	for M in src/Makefile openvt/Makefile ; do
		[ -r $M.OLD ] || mv $M $M.OLD || exit 1
		cat $M.OLD \
			| sed '/^CC[ 	]*=/ s%g*cc%'${FR_CROSS_CC}'%' \
			> $M || exit 1
	done

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g all || exit 1
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	exit 1
	;;
esac
