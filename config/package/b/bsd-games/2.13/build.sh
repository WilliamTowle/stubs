#!/bin/sh
# 2008-06-22 (prev 2006-07-16)

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	if [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/'
		ADD_LIBC_NCURSES='-L'${FR_LIBCDIR}'/lib -lncurses'
	else
		echo "$0: Confused -- no ncurses.h" 1>&2
		exit 1
	fi

	if [ ! -d ${FR_LIBCDIR}/include/err_h ] ; then
		echo "No Kragen's err.h build" 1>&2
		exit 1
	else
		DIR_KRAGENSERRH=${FR_LIBCDIR}/include/err_h
		ADD_INCL_KRAGENSERRH=-I${DIR_KRAGENSERRH}
		ADD_LIBS_KRAGENSERRH=-lerr
	fi

	if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
		echo "$0: Aborting -- no 'fakeroot'" 1>&2
		exit 1
	fi

	[ -d bsd-games-${PKGVER} ] && cd bsd-games-${PKGVER}

	cat > config.params << EOF
bsd_games_cfg_non_interactive=y
bsd_games_cfg_install_prefix=${INSTTEMP}
EOF

	CC=${FR_CROSS_CC} \
	  CFLAGS="-O2 ${ADD_INCL_NCURSES}" \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${TARGET_CPU} \
		  --disable-nls \
		  || exit 1
#		  --with-included-regex \

	if [ -r config.h ] ; then
		echo "config.h found" 1>&2
		exit 1
#		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1
#		cat config.h.OLD \
#			| sed '/HAVE_WCHAR_H/	s%^/\* %%' \
#			| sed '/HAVE_WCHAR_H/	s% \*/$%%' \
#			| sed '/HAVE_WCHAR_T/	s%define%undef%' \
#			| sed '/HAVE_WCHAR_T/	s% 1%%' \
#			| sed '/HAVE_WCTYPE_H/	s%^/\* %%' \
#			| sed '/HAVE_WCTYPE_H/	s% \*/$%%' \
#			> config.h || exit 1
	fi

	case ${PKGVER} in
	2.13)
#	cat <<EOF > GNUmakefile
##!`which make`
#
#CC=${FR_CROSS_CC}
#
#.SUFFIXES:
#.SUFFIXES: .c .o
#
#.c.o: \$*.c \$*.h
#	\${CC} \${CFLAGS} -c \$*.c -o \$@
#
#EOF

		# cross compile as appropriate
		[ -r Makeconfig.OLD ] || mv Makeconfig Makeconfig.OLD || exit 1
		cat Makeconfig.OLD \
			| sed	' /^CC[ 	]*:*=/	s%g*cc%'${FR_CROSS_CC}'%
				; /^OPTIMIZE[ 	]*:*=/	s/-g//
				; /^CFLAGS[ 	]*:*=/	s%$%'${ADD_INCL_KRAGENSERRH}'%
				' > Makeconfig || exit 1

		# 'setup' files don't use HOSTCC
		# boggle depends on real /usr/lib/dict/words
		# cribbage wants vfork()
		# dm wants getloadavg()
		[ -r GNUmakefile.OLD ] || mv GNUmakefile GNUmakefile.OLD || exit 1
		cat GNUmakefile.OLD \
			| sed	' /setup:/,+2 s%$(CC)%'${FR_HOST_CC}'%
				; /strfile:/,+2 s%$(CC)%'${FR_HOST_CC}'%
				; /initdeck:/,+2 s%$(CC)%'${FR_HOST_CC}'%
				; /all:/	s/boggle[^ ]*//g
				; /all:/	s/cribbage[^ ]*//g
				; /all:/	s/dm[^ ]*//g
				; /(CC).*(LDFLAGS)/	s%(BASE_LIBS)%(BASE_LIBS) '${ADD_LIBS_KRAGENSERRH}'%
				' > GNUmakefile || exit 1

		[ -r phantasia/Makefrag.OLD ] || mv phantasia/Makefrag phantasia/Makefrag.OLD || exit 1
		cat phantasia/Makefrag.OLD \
			| sed	' /^	.*cp /	s/$(PHANTASIA_DIR)/$(INSTALL_PREFIX)$(PHANTASIA_DIR)/
				' > phantasia/Makefrag || exit 1
#		[ -r phantasia/Makefrag.OLD ] || mv phantasia/Makefrag phantasia/Makefrag.OLD || exit 1
#		cat phantasia/Makefrag.OLD \
#			| sed	' /^	/	s/$(PHANTASIA_DIR)/$(INSTALL_PREFIX)$(PHANTASIA_DIR)/
#				' > phantasia/Makefrag || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	make || exit 1

	# replace host-comiled things for final install:
	( cd fortune/strfile || exit 1
		rm -f strfile.o strfile || exit 1
		cd - || exit 1
		make HOSTCC=${FR_HOST_CC} fortune/strfile/strfile
	) || exit 1

# INSTALL...
	#mkdir -p ${INSTTEMP}/usr/bin/ || exit 1
	${FR_TH_ROOT}/usr/bin/fakeroot \
		make DESTDIR=${INSTTEMP} install || exit 1
#	make DESTDIR=${INSTTEMP} install || exit 1
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
