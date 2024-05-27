#!/bin/sh
# 07/06/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -x ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc/bin/${TARGET_CPU}-uclibc-gcc ] ; then
		UCPATH=${TCTREE}/usr/${TARGET_CPU}-linux-uclibc
	else
		UCPATH=${TCTREE}/usr/${TARGET_CPU}-linux
	fi
	GCCINCDIR=`${UCPATH}/bin/${TARGET_CPU}-uclibc-gcc -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

	PATH=${UCPATH}/bin:${PATH} \
	  CC=${TARGET_CPU}-uclibc-gcc \
		./configure --prefix=/usr \
		 --build=`uname -m` --host=${TARGET_CPU} --target=${TARGET_CPU} \
		 --disable-nls --disable-largefile || exit 1

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^prefix / s%/usr%${DESTDIR}/usr%' \
			| sed '/^CFLAGS/ s%+=%= -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
			| sed '/^CFLAGS/ s/ -g / /' \
			> ${MF} || exit 1
	done || exit 1

# BUILD...
	PATH=${UCPATH}/bin:${PATH} \
		make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
	mkdir -p ${INSTTEMP}/etc || exit 1
	cp xinetd/sample.conf ${INSTTEMP}/etc/sample-xinetd.conf || exit 1
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
