#!/bin/sh
# 09/07/2006

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

	if [ ! -d ${FR_LIBCDIR}/err_h ] ; then
		echo "No Kragen's err.h build" 1>&2
		exit 1
	else
		DIR_KRAGENSERRH=${FR_LIBCDIR}/err_h
		ADD_INCL_KRAGENSERRH=-I${DIR_KRAGENSERRH}
		ADD_LIBS_KRAGENSERRH=-lerr
	fi

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed	' /^CC *:/	s%g*cc%'${FR_CROSS_CC}'%
				; /^	/	s/gcc /$(CC) /
				; /^CFLAGS *:/	s%"$%'${ADD_INCL_KRAGENSERRH}'"%
				' > ${MF} || exit 1
	done

#	[ -r virus.c.OLD ] || mv virus.c virus.c.OLD || exit 1
#	cat virus.c.OLD \
#		| sed 's/err(1/fprintf(stderr/' \
#		> virus.c || exit 1

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
#	PATH=${FR_LIBCDIR}/bin:${PATH} \
#		CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
#		  ./mkvirus || exit 1
	  ./mkvirus || exit 1

# INSTALL...
	# BROKEN: ./mkvirus-inst || exit 1
	mkdir -p ${INSTTEMP}/bin || exit 1
	cp virus ${INSTTEMP}/bin || exit 1
	( cd ${INSTTEMP}/bin && ln -sf virus vi ) || exit 1
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
