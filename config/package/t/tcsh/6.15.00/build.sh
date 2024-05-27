#!/bin/sh
# 2007-11-25

# TODO:- link fails - various undeclared entities

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

	if [ ! -r ${FR_LIBCDIR}/lib/libiconv.a ] ; then
		echo "$0: Confused -- libiconv.a not found" 1>&2
		exit 1
	else
		ADD_LIBS_ICONV='-L'${FR_LIBCDIR}
	fi

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
		ADD_LDFLAGS_NCURSES='-lncurses'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

#	if [ ! -r ${FR_LIBCDIR}/lib/libtermcap.a ] ; then
#		echo "$0: Confused -- libtermcap.a not found" 1>&2
#		exit 1
#	fi


	case ${PKGVER} in
	6.14.00)
#		PATH=${FR_LIBCDIR}/bin:${PATH}
		  CC=${FR_CROSS_CC} \
		  ac_cv_header_wchar_h=no \
			./configure --prefix=/usr \
			  --host=`uname -m`-linux --build=${TARGET_CPU} \
			  --disable-nls --disable-largefile \
			  || exit 1

		for CF in config/linux config_f.h config_p.h ; do
			[ -r ${CF}.OLD ] || mv ${CF} ${CF}.OLD || exit 1
			cat ${CF}.OLD \
				| sed '/_FILE_OFFSET_BITS/ s/ 64/ 32/' \
				| sed '/_FILE_OFFSET_BITS/ s/ 64/ 32/' \
				| sed '/_LARGEFILE/ s/define/undef/' \
				| sed '/define SHORT_STRINGS/ s/define/undef/' \
				> ${CF} || exit 1
		done

#		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#		cat config.h.OLD \
#			| sed '/HAVE_ICONV/	s/define/undef/' \
#			| sed '/HAVE_ICONV/	s/ 1//' \
#			> config.h || exit 1

		for SF in sh.c sh.func.c sh.glob.c sh.print.c ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's/MB_CUR_MAX/sizeof(char)/' \
				> ${SF} || exit 1
		done

#		[ -r glob.c.OLD ] || mv glob.c glob.c.OLD || exit 1
#		cat glob.c.OLD \
#			| sed 's/CHAR/char/' \
#			> glob.c || exit 1
	;;
	6.15.00)
		  CC=${FR_CROSS_CC} \
		  ac_cv_func_getpgrp_void=yes \
		  ac_cv_func_setpgrp_void=yes \
			./configure --prefix=/usr \
			  --host=`uname -m`-linux --build=${TARGET_CPU} \
			  || exit 1

#		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
#		cat Makefile.OLD \
#			| sed '/^LIBES/ s/-ltermcap/'${ADD_LDFLAGS_NCURSES}'/' \
#			> Makefile || exit 1

		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
		cat config.h.OLD \
			| sed '/HAVE_DECL_GETHOSTNAME/ s/0/1/' \
			> config.h || exit 1

		for CF in config/linux config_f.h config_p.h ; do
			[ -r ${CF}.OLD ] || mv ${CF} ${CF}.OLD || exit 1
			cat ${CF}.OLD \
				| sed '/_FILE_OFFSET_BITS/ s/ 64/ 32/' \
				| sed '/_FILE_OFFSET_BITS/ s/ 64/ 32/' \
				| sed '/_LARGEFILE/ s/define/undef/' \
				| sed '/NLS_CATALOGS/ s/define/undef/' \
				| sed '/define SHORT_STRINGS/ s/define/undef/' \
				> ${CF} || exit 1
		done

		for SF in sh.c sh.func.c sh.glob.c sh.print.c \
				ed.inputl.c ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's/MB_CUR_MAX/sizeof(char)/' \
				> ${SF} || exit 1
		done
#
##		[ -r glob.c.OLD ] || mv glob.c glob.c.OLD || exit 1
##		cat glob.c.OLD \
##			| sed 's/CHAR/char/' \
##			> glob.c || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	6.14.00)
		make CC=${FR_HOST_CC} gethost LDFLAGS=-lncurses || exit 1
#		PATH=${FR_LIBCDIR}/bin:${PATH}
			make LDFLAGS="-lncurses" || exit 1
	;;
	6.15.00)
		make CC=${FR_HOST_CC} gethost EXTRALIBS='' || exit 1
		make LDFLAGS="${ADD_LIBS_ICONV}" || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	6.14.00)
		make installroot=${INSTTEMP} install || exit 1
	;;
	6.15.00)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
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
