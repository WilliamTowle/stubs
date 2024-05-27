#!/bin/sh
# 05/03/2006

#TODO:- revert to 050915 -- success?
#TODO:- revert to 051031 -- success?
#TODO:- revert to 051107 -- success?
#TODO:- 'mkey' and 'inv' and cross- vs host- compiler for them?

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

	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
		# toolchain 0.7.x and later
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.6.4 and prior
		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	case ${PKGVER} in
	050915)
		[ -r mk.config.OLD ] || mv mk.config mk.config.OLD || exit 1
		cat mk.config.OLD \
			| sed '/^INSTALL=/ s%/usr.*%'${FR_TH_ROOT}'/bin/install%' \
			| sed '/^EUC=/ s/^/#/' \
			| sed '/=\/usr\/ucb/ 	s/ucb$/local/' \
			| sed '/=\/usr\/ucb/	s/ucblib$/local/' \
			| sed '/=\/usr\/ucb/	s%ucblib/%local/%' \
			> mk.config || exit 1

		find ./ -name Makefile.mk | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/-o makedev/	s/(CC)/(HOSTCC)/' \
				| sed '/^	/	s%$(CC)%'${FR_CROSS_CC}'%' \
				| sed 's/(ROOT)/(DESTDIR)/g' \
				> ${MF} || exit 1
		done

		for SF in \
			troff/n1.c \
			troff/n9.c \
			troff/troff.d/dpost.d/dpost.c \
		; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
				> ${SF} || exit 1
		done

	;;
#	051031)
#		[ -r mk.config.OLD ] || mv mk.config mk.config.OLD || exit 1
#		cat mk.config.OLD \
#			| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
#			| sed '/^CCC *=/ s%g*c[+]*%'`echo ${FR_CROSS_CC} | sed 's/gcc$/g++/'`'%' \
#			| sed '/^INSTALL=/ s%/usr.*%'${FR_TH_ROOT}'/bin/install%' \
#			| sed '/^EUC=/ s/^/#/' \
#			> mk.config || exit 1
#
#		find ./ -name Makefile.mk | while read MF ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/-o genutf8/	s/CC/HOSTCC/' \
#				| sed '/-o makedev/	s/CC/HOSTCC/' \
#				> ${MF} || exit 1
#		done
#
#		for SF in \
#			troff/troff.d/dpost.d/dpost.c \
#			vgrind/vfontedpr.c \
#		; do
#			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
#			cat ${SF}.OLD \
#				| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
#				> ${SF} || exit 1
#		done
#	;;
#	051107)
#		[ -r mk.config.OLD ] || mv mk.config mk.config.OLD || exit 1
#		cat mk.config.OLD \
#			| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
#			| sed '/^CCC *=/ s%g*c[+]*%'`echo ${FR_CROSS_CC} | sed 's/gcc$/g++/'`'%' \
#			| sed '/^INSTALL=/ s%/usr.*%'${FR_TH_ROOT}'/bin/install%' \
#			| sed '/^EUC=/ s/^/#/' \
#			> mk.config || exit 1
#
#		# (v051031 needed HOSTCC sometimes)
#		find ./ -name Makefile.mk | while read MF ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/-o genutf8/	s/CC/HOSTCC/' \
#				| sed '/-o makedev/	s/CC/HOSTCC/' \
#				| sed 's/(ROOT)/(DESTDIR)/g' \
#				> ${MF} || exit 1
#		done
#
#		# (v051031) MB_CUR_MAX is not available without WCHAR support
#		for SF in \
#			troff/troff.d/dpost.d/dpost.c \
#			troff/n1.c \
#			vgrind/vfontedpr.c \
#		; do
#			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
#			cat ${SF}.OLD \
#				| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
#				> ${SF} || exit 1
#		done
#	;;
	051227)
		[ -r mk.config.OLD ] || mv mk.config mk.config.OLD || exit 1
		cat mk.config.OLD \
			| sed '/^CC *=/ s%g*cc%'${FR_CROSS_CC}'%' \
			| sed '/^CCC *=/ s%g*c[+]*%'`echo ${FR_CROSS_CC} | sed 's/gcc$/g++/'`'%' \
			| sed '/^INSTALL=/ s%/usr.*%'${FR_TH_ROOT}'/bin/install%' \
			| sed '/^EUC=/ s/^/#/' \
			| sed '/=\/usr\/ucb/ 	s/ucb$/local/' \
			| sed '/=\/usr\/ucb/	s/ucblib$/local/' \
			| sed '/=\/usr\/ucb/	s%ucblib/%local/%' \
			> mk.config || exit 1

		find ./ -name Makefile.mk | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/-o makedev/	s/CC/HOSTCC/' \
				| sed '/^	/	s/(ROOT)/(DESTDIR)/g' \
				> ${MF} || exit 1
		done
#				| sed '/-o genutf8/	s/CC/HOSTCC/' \
#				| sed '/-o inv/	s/CC/HOSTCC/' \
#				| sed '/-o mkey/	s/CC/HOSTCC/' \

		for SF in \
			troff/troff.d/dpost.d/dpost.c \
			troff/n9.c \
			troff/n1.c \
			vgrind/vfontedpr.c \
		; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
				> ${SF} || exit 1
		done
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	# path to include bison
	PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
		make HOSTCC=${FR_HOST_CC} || exit 1

# INSTALL...
	case ${PKGVER} in
	050915)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
#	051031|051107)
#		find ./ -name Makefile | while read MF ; do
#			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
#			cat ${MF}.OLD \
#				| sed '/usr\/ucb/	s/ucb$/local/' \
#				| sed '/usr\/ucb/	s/ucblib$/local/' \
#				| sed '/usr\/ucb/	s%ucblib/%local/%' \
#				> ${MF} || exit 1
#		done
#		make DESTDIR=${INSTTEMP} install || exit 1
#	;;
	051227)
		make DESTDIR=${INSTTEMP} install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

	echo "*** CHECKS ***"
	find ${INSTTEMP} -name inv | wc -l || exit 1
	find ${INSTTEMP} -name makedev | wc -l || exit 1
	find ${INSTTEMP} -name mkey | wc -l || exit 1
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
