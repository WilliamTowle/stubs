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

	case ${PKGVER} in
	2.1.0)
		[ -r ./depcomp ] || cp ${TCTREE}/usr/share/automake/depcomp ./
#		find ./ -name Makefile.in | while read MF ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed 's/@AMDEPBACKSLASH@/\\\\/' \
#				| sed '/^@AMDEP_TRUE/	s/^/#/' \
#				| sed '/^@am__fastdepCC_TRUE/	s/^/#/' \
#				| sed '/am__fastdepCC_FALSE/	s/^@.*@//' \
#				> ${MF} || exit 1
#		done
		;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
		;;
	esac

	[ -r Makefile.in.OLD ] || mv Makefile.in Makefile.in.OLD || exit 1
	cat Makefile.in.OLD \
		| sed '/^AUTOCONF/	s/=.*/= true/' \
		| sed '/^AUTOMAKE/	s/=.*/= true/' \
		> Makefile.in || exit 1

	PATH=${FR_LIBCDIR}/bin:${PATH} \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-gettext \
		  || exit 1

	[ -r i18n.h ] && mv i18n.h i18n.h.OLD || exit 1
	cat i18n.h.OLD \
		| sed 's%gettext *(str)%(str) /* gettext(str) */%' \
		> i18n.h

# | sed '/^DEFS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed 's%/usr/src/linux%'${TCTREE}'/usr/src/linux%g' \
			| sed '/^CFLAGS/ s/ -g //' \
			> ${MF} || exit 1
	done

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CC=${FR_CROSS_CC} \
		  || exit 1

# INSTALL...
	MSGF=`which msgfmt 2>/dev/null`
	if [ "${MSGF}" ] ; then
		make DESTDIR=${INSTTEMP} install || exit 1
	else
		make DESTDIR=${INSTTEMP} SUBDIRS='' install || exit 1
	fi
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
