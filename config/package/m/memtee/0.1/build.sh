#!/bin/sh
# 13/03/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-cross-linux-gcc
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

#	# without-included-regex here, as uClibc conflicts
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#	  CC=${FR_CROSS_CC} \
#		./configure --prefix=/usr --bindir=/bin \
#		  --host=`uname -m` --build=${TARGET_CPU} \
#		  --disable-largefile --disable-nls \
#		  --without-included-regex \
#		  || exit 1

# | sed 's%(CC)%(CC) -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^DEBUG/	s/-g//' \
		| sed '/^	/ s% /usr% ${DESTDIR}/usr%' \
		> Makefile || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		make CC=${FR_CROSS_CC} \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	#mkdir -p ${INSTTEMP}/usr/share/man/man1 || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

#make_th()
#{
#}

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
