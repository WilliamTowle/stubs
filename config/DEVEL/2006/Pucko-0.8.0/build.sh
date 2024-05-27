#!/bin/sh
# 06/02/2006

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

	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
		ADD_LDFLAGS_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	if [ -d ${FR_LIBCDIR}/usr/include/SDL ] ; then
		ADD_INCL_SDL='-I'${FR_LIBCDIR}'/usr/include/'
		ADD_LDFLAGS_SDL='-L'${FR_LIBCDIR}'/usr/lib'
	else
		echo "$0: Confused -- no SDL built" 1>&2
		exit 1
	fi

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES} ${ADD_INCL_SDL}" \
	  LDFLAGS="${ADD_LDFLAGS_SDL}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls \
		  --with-included-regex \
		  || exit 1

	case ${PKGVER} in
	0.8.0)
		[ -r src/id3.c.OLD ] || mv src/id3.c src/id3.c.OLD || exit 1
		cat src/id3.c.OLD \
			| sed 's/id3_tag_list \*tag_list/tag_list/' \
			| sed '/make sure/ s/^/id3_tag_list *tag_list;/' \
			| sed 's/id3_content \*content/content/' \
			| sed '/make sure/ s/^/id3_content *content;/' \
			| sed 's/id3_text_content \*text/text/' \
			| sed '/make sure/ s/^/id3_text_content *text;/' \
			| sed 's/char \*res/res/' \
			| sed '/make sure/ s/^/char *res;/' \
			| sed 's/id3_content \*artist_content/artist_content/' \
			| sed '/make sure/ s/^/id3_content *artist_content;/' \
			| sed 's/id3_content \*title_content/title_content/' \
			| sed '/make sure/ s/^/id3_content *title_content;/' \
			| sed 's/id3_text_content \*artist_text/artist_text/' \
			| sed '/make sure/ s/^/id3_text_content *artist_text;/' \
			| sed 's/id3_text_content \*title_text/title_text/' \
			| sed '/make sure/ s/^/id3_text_content *title_text;/' \
			| sed '/char result/	s/.*/strcpy(result, "");/' \
			| sed '/make sure/ s/^/char result[100];/' \
			> src/id3.c || exit 1

		[ -r src/gui_id3.c.OLD ] || mv src/gui_id3.c src/gui_id3.c.OLD || exit 1
		cat src/gui_id3.c.OLD \
			| sed 's/; *;$/;/' \
			> src/gui_id3.c || exit 1

		[ -r src/pucko.c.OLD ] || mv src/pucko.c src/pucko.c.OLD || exit 1
		cat src/pucko.c.OLD \
			| sed '/Volume:/	s/^/char text[100];/' \
			| sed '/ char text.*""/ s/.*/strcpy(text, "");/' \
			> src/pucko.c || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LDFLAGS_NCURSES} || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
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
