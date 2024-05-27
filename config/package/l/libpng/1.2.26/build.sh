#!/bin/sh
# 26/08/2006

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
		echo "$0: Failed: No zlib.h?" 1>&2
		exit 1
	fi

	if [ -r Makefile ] ; then
		echo "$0: Unexpected: Makefile exists" 1>&2
		exit 1
	fi

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	cat scripts/makefile.linux \
		| sed 's%CC=gcc%CC='${FR_CROSS_CC}'%' \
		> Makefile || exit 1

# BUILD...

#		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
#		  || exit 1
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/include/libpng12 || exit 1

#		make CCPREFIX=${TARGET_CPU}-uclibc-g DESTDIR=${INSTTEMP} install || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_tc()
{
# CONFIGURE...
	PHASE=tc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ ! -r ${FR_LIBCDIR}/include/zlib.h ] ; then
		echo "$0: Failed: No zlib.h?" 1>&2
		exit 1
	fi

	if [ -r Makefile ] ; then
		echo "$0: Unexpected: Makefile exists" 1>&2
		exit 1
	fi

# | sed '/^CFLAGS/ s%=%= -nostdinc -I'${TCTREE}/${FR_UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	cat scripts/makefile.linux \
		| sed	' /^prefix=/	s%/.*%'${FR_LIBCDIR}'%
			; s%CC=gcc%CC='${FR_CROSS_CC}'%
			' > Makefile || exit 1

# BUILD...

#		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
#		  || exit 1
	make || exit 1

# INSTALL...
	mkdir -p ${FR_LIBCDIR}/include/libpng12 || exit 1
	make DESTDIR='' install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
toolchain-cross)
	INSTTEMP=${TCTREE} make_tc || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
