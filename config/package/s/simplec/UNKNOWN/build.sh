#!/bin/sh
# 27/06/2004

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

	[ -r build.OLD ] || mv build build.OLD || exit 1
	cat build.OLD \
		| sed '/^gcc / s/$/|| exit 1/' \
		| sed '/^as / s/$/|| exit 1/' \
		| sed 's%^gcc%'${TARGET_CPU}'-uclibc-gcc -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
		> build || exit 1
	chmod a+x build || exit 1

	[ -r install.OLD ] || mv install install.OLD || exit 1
	cat install.OLD \
		| sed '/^mkdir / s/$/|| exit 1/' \
		| sed '/^cp / s/$/|| exit 1/' \
		| sed 's%/usr%${DESTDIR}/usr%' \
		> install || exit 1
	chmod a+x install || exit 1

# BUILD...
	PATH=${UCPATH}/bin:${PATH} \
		sh -x ./build || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/share/scc || exit 1
	[ -r ${INSTTEMP}/usr/share/scc/lib ] \
		&& rm -rf ${INSTTEMP}/usr/share/scc/lib
	DESTDIR=${INSTTEMP} ./install || exit 1
	[ -r ${INSTTEMP}/usr/share/scc/examples ] \
		&& rm -rf ${INSTTEMP}/usr/share/scc/examples
	cp -r test ${INSTTEMP}/usr/share/scc/examples || exit 1
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
