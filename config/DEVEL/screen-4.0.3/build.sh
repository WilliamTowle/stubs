#!/bin/sh -x
# 2008-09-06

# TODO:- cannot cross compile, checks for "POSIXized ISC" (v3.9.9)

# TODO:- "configure: error: cannot run test program while cross
# TODO: compiling" - while is seeking for strerror()? (v4.0.2)


[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	  ac_cv_search_strerror=no \
	  ac_cv_func_strerror=yes \
	  CC=${FR_CROSS_CC} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --disable-nls --disable-largefile \
		  || exit 1
#		  --host=`uname -m` --build=${TARGET_CPU}

#echo "FIX GCCINCDIR"
#	for MF in `find ./ -name Makefile` ; do
#		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#		cat ${MF}.OLD \
#			| sed '/^INCLUDES/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#			> ${MF} || exit 1
#	done || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	make prefix=${INSTTEMP}/usr install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
