#!/bin/sh
# 2008-09-06

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -d ${PKGNAME}-${PKGVER} ] ; then
		for PF in *patch ; do
			cat ${PF} | ( cd ${PKGNAME}-${PKGVER} && patch -Np1 -i - )
		done
		cd ${PKGNAME}-${PKGVER}
	fi

	case ${PKGVER} in
	1.12)
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
	;;
	1.14.1)
		CC=${FR_CROSS_CC} \
		  ac_cv_func_malloc_nonnull=yes \
		  ac_cv_func_setpgrp_void=yes \
		  CFLAGS='-O2' \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${FR_TARGET_DEFN} \
			  || exit 1

		[ -r src/Makefile.OLD ] || mv src/Makefile src/Makefile.OLD || exit 1
		cat src/Makefile.OLD \
			| sed 's/-Wunused-function/ /' \
			| sed 's/-Wunused-label/ /' \
			| sed 's/-Wunused-variable/ /' \
			| sed 's/-Wunused-value/ /' \
			> src/Makefile || exit 1 \

		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed '/define.*rpl_.*alloc/ { s%^%/* % ; s%$% */% }' \
			> config.h || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_TH_ROOT}/usr/bin/flex ] ; then
		echo "$0: Confused: No 'flex' in toolchain" 1>&2
		exit 1
	fi

	PHASE=dc do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	1.12)
		make || exit 1
	;;
	1.14.1)	# ignores CC= passed to ./configure
		make CC=${FR_CROSS_CC} || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	exit 1
;;
esac
