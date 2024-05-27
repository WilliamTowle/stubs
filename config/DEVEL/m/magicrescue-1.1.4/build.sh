#!/bin/sh
# 10/02/2005

#TODO:- claims compiler doesn't work (ie. won't cross-compile)

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

	# Barf! ./configure is a poor workalike that can't spot
	# that we're cross compiling :( {v1.1.x}
#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  CC=${FR_HOST_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-largefile --disable-nls \
		  || exit 1

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC/	s/gcc/${CCPREFIX}cc/' \
		| sed '/^DBM_LDFLAGS/ s/^/#/' \
		| sed 's/(PREFIX)/(DESTDIR)$(PREFIX)/' \
		>> Makefile || exit 1

	[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
	cat config.h.OLD \
		| sed '/DBM_H_/	s%^%/* %' \
		| sed '/DBM_H_/	s%$% */%' \
		| sed '/HAVE_NDBM/	s%^%/* %' \
		| sed '/HAVE_NDBM/	s%$% */%' \
		> config.h || exit 1

	[ -r src/largefile.h.OLD ] || mv src/largefile.h src/largefile.h.OLD || exit 1
	cat src/largefile.h \
		| sed '/_FILE_OFFSET_BITS/ s/64/32/' \
		> src/largefile.h || exit 1

# BUILD...
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr || exit 1
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
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
