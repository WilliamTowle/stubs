#!/bin/sh
# 09/07/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -d ${FR_LIBCDIR}/include/err_h ] ; then
		echo "No Kragen's err.h build" 1>&2
		exit 1
	else
		DIR_KRAGENSERRH=${FR_LIBCDIR}/include/err_h
		ADD_INCL_KRAGENSERRH=-I${DIR_KRAGENSERRH}
		ADD_LIBS_KRAGENSERRH=-lerr
	fi

	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed	' /^CC *:/	s%g*cc%'${FR_CROSS_CC}'%
				; /^	/	s/gcc /$(CC) /
				; /^CFLAGS *:/	s%"$%'${ADD_INCL_KRAGENSERRH}'"%
				' > ${MF} || exit 1
	done

	[ -r mkvirus.OLD ] || mv mkvirus mkvirus.OLD || exit 1
	cat mkvirus.OLD \
		| sed	' /^[gsc]/ s/$/ || exit 1/
			; s%gcc%'${FR_CROSS_CC}' '${ADD_INCL_KRAGENSERRH}' '${ADD_LIBS_KRAGENSERRH}'%
			' > mkvirus || exit 1
	chmod a+x mkvirus || exit 1

	[ -r mkvirus-inst.OLD ] \
		|| mv mkvirus-inst mkvirus-inst.OLD || exit 1
	cat mkvirus-inst.OLD \
		| sed	' s%/opt/virus%'${INSTTEMP}'%
			' > mkvirus-inst || exit 1
	chmod a+x mkvirus-inst || exit 1

# BUILD...
	  ./mkvirus || exit 1

# INSTALL...
	case ${PKGVER} in
	0.0.5|0.0.6)
		mkdir -p ${INSTTEMP}/bin || exit 1
		cp virus ${INSTTEMP}/bin || exit 1
		( cd ${INSTTEMP}/bin && ln -sf virus vi ) || exit 1
	;;
#	BROKEN)
#		./mkvirus-inst || exit 1
#	;;
	*)	echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
