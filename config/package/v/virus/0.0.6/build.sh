#!/bin/sh
# 03/01/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/cross-utils/bin/${TARGET_CPU}-cross-linux-gcc ] ; then
		# 'sanitc' compiler environment, 25/11/2004
		FR_UCPATH=cross-utils
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-cross-linux-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	elif [ -d ${TCTREE}/usr/${TARGET_CPU}-linux-uclibc ] ; then
		# uClibc-wrapper build environment
		FR_UCPATH=/usr/${TARGET_CPU}-linux-uclibc
		FR_CROSS_CC=${TCTREE}/${FR_UCPATH}/bin/${TARGET_CPU}-uclibc-gcc
		FR_LIBCDIR=${TCTREE}/${FR_UCPATH}
	else
		echo "$0: Confused -- FR_UCPATH not determined" 1>&2
		exit 1
	fi || exit 1
	GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^CC/ s/gcc/${CCPREFIX}cc/' \
			| sed '/^	/ s/gcc /$(CC) /' \
			> ${MF} || exit 1
	done || exit 1

	[ -r virus.c.OLD ] || mv virus.c virus.c.OLD || exit 1
	cat virus.c.OLD \
		| sed 's/err(1/fprintf(stderr/' \
		> virus.c || exit 1

	[ -r mkvirus.OLD ] || mv mkvirus mkvirus.OLD || exit 1
	cat mkvirus.OLD \
		| sed '/^[gsc]/ s/$/ || exit 1/' \
		| sed 's%gcc%'${FR_CROSS_CC}'%' \
		> mkvirus || exit 1
	chmod a+x mkvirus || exit 1

	[ -r mkvirus-inst.OLD ] \
		|| mv mkvirus-inst mkvirus-inst.OLD || exit 1
	cat mkvirus-inst.OLD \
		| sed 's%/opt/virus%'${INSTTEMP}'%' \
		> mkvirus-inst || exit 1
	chmod a+x mkvirus-inst || exit 1

# BUILD...
	PATH=${FR_LIBCDIR}/bin:${PATH} \
		CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
		  ./mkvirus || exit 1

# INSTALL...
	# BROKEN: ./mkvirus-inst || exit 1
	mkdir -p ${INSTTEMP}/bin || exit 1
	cp virus ${INSTTEMP}/bin || exit 1
	( cd ${INSTTEMP}/bin && ln -sf virus vi ) || exit 1
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
