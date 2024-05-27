#!/bin/sh
# 10/02/2005

#TODO:- assumption FILE_OFFSET_BITS will be 64, not 32
#TODO:- various other compile failures

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

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^DIET/ s/^/#/' \
		| sed '/^CFLAGS/ s/-Os/-O2/' \
		| sed '/strip / s/$(CROSS)//' \
		| sed 's/@-linux-/@-uclibc-/' \
		\
		| sed '/^[b-z][a-z]* / s/^/ /' \
		| sed '/[a-z]$/ s/$/ /' \
		| sed 's/ allinone / /' \
		| sed 's/ chmod / /' \
		| sed 's/ chown / /' \
		| sed 's/ chgrp / /' \
		| sed 's/ cp / /' \
		| sed 's/ dd / /' \
		| sed 's/ dmesg / /' \
		| sed 's/ du / /' \
		| sed 's/ env / /' \
		| sed 's/ domainname / /' \
		| sed 's/ install / /' \
		| sed 's/ ls / /' \
		| sed 's/ mktemp / /' \
		| sed 's/ mv / /' \
		| sed 's/ md5sum / /' \
		| sed 's/ rm / /' \
		| sed 's/ soscp / /' \
		| sed 's/ strings / /' \
		| sed 's/ tar / /' \
		| sed 's/ tail / /' \
		| sed 's/ test / /' \
		| sed 's/ touch / /' \
		| sed 's/ truncate / /' \
		| sed 's/ uudecode / /' \
		| sed 's/ uuencode / /' \
		| sed 's/ which / /' \
		> Makefile || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make ${TARGET_CPU} || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/bin || exit 1
	make DESTDIR=${INSTTEMP} prefix='' install || exit 1
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
