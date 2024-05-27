#!/bin/sh
# 07/12/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
BOGUS_DC		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	  CC=${FR_CROSS_CC} \
	  ac_cv_func_setvbuf_reversed=no \
		./configure --prefix=/usr \
		  --bindir=/bin --localstatedir=/var \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  || exit 1

# | sed '/^DEFS/ s%=%= -nostdinc -I'${GCCINCDIR}' -I'${FR_LIBCDIR}'/include %' \
	for MF in `find ./ -name Makefile` ; do
		mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CFLAGS/ s/ -g //' \
			> ${MF} || exit 1
	done

# BUILD...
	case ${PKGVER} in
	2.0)

			make || exit 1
		;;
	2.0.15)

		  AR=`echo ${FR_CROSS_CC} | sed 's/gcc$/ar/'` \
			make LDFLAGS='-lm' || exit 1
		;;
	*)
		echo "$0: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	( cd ${INSTTEMP} && ( \
		( cd bin && ln -sf test '[' ) ;\
		mkdir -p var/run ;\
		touch var/run/utmp \
	) || exit 1 ) || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
BOGUS_DC		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

	CC=${FR_HOST_CC} \
		./configure \
		 --prefix=${INSTTEMP}/usr --bindir=${INSTTEMP}/bin \
		 --localstatedir=${INSTTEMP}/var \
		 || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make install || exit 1
	( cd ${INSTTEMP} && ( \
		( cd bin && ln -sf test '[' ) ;\
		mkdir -p var/run ;\
		touch var/run/utmp \
	) || exit 1 ) || exit 1
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
