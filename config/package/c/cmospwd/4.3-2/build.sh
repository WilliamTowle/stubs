#!/bin/sh
# 01/03/2004

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


# BUILD...
	PATH=${UCPATH}/bin:${PATH} \
		${TARGET_CPU}-uclibc-gcc  \
		  -nostdinc -I${UCPATH}/include -I${GCCINCDIR} -I${TCTREE}/usr/include \
		  cmospwd.c -o cmospwd \
		  || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/sbin || exit 1
	cp cmospwd ${INSTTEMP}/usr/sbin || exit 1
}

#make_th()
#{
## CONFIGURE...
## BUILD...
## INSTALL...
#}

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
