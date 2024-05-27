#!/bin/sh
# 22/02/2007

#TODO:- `make install` does tests! (cross compilation -> failure)
#TODO:- version control? This is good for 22.6.x

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

	# frlx 0.7.3[pre3]
	if [ ! -r ${FR_TH_ROOT}/usr/bin/as86 ] ; then
		echo "$0: CONFIGURE: No 'bin86' installed" 1>&2
		exit 1
	elif [ -r ${FR_TH_ROOT}/usr/bin/as86.real ] ; then
		echo "$0: CONFIGURE: installed 'bin86' is too old" 1>&2
		exit 1
	fi

	find ./ -name [Mm]akefile | while read MF ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed	' /^CC *=/	s%g*cc%'${FR_CROSS_CC}'%
				; /^AS8*6* *=/	s%as%'${FR_TH_ROOT}'/usr/bin/as%
				; /^LD8*6* *=/	s%ld%'${FR_TH_ROOT}'/usr/bin/ld%
				; s%/usr/bin/bcc%'${FR_TH_ROOT}'/usr/bin/bcc%
				; /^CFLAGS/ s/ -g //
				; /^SBIN_DIR/ s%/%${DESTDIR}/usr/%
				; /^CFG_DIR/ s%/%${DESTDIR}/usr/%
				; /^USRSBIN_DIR/ s%/usr/%${DESTDIR}/usr/%
				; s%/usr/bin/manpath%/native/usr/bin/manpath%
				; s%/usr/man%${DESTDIR}/usr/man%
				; /^	/	s%tail -%'${FR_TH_ROOT}'/bin/tail -n -%
				' > ${MF} || exit 1
	done

	# (11/09/2004) test for lseek64() is bobbins
	[ -r partition.c.OLD ] || mv partition.c partition.c.OLD \
		|| exit 1
	cat partition.c.OLD \
		| sed '/__GLIBC_MINOR__/ s%__%1 /* __%' \
		| sed '/__GLIBC_MINOR__/ s%$% */%' \
		| sed '/__NR__llseek/ s%defined%0 /* defined%' \
		| sed '/__NR__llseek/ s%$% */%' \
		> partition.c || exit 1

	case ${PKGVER} in
	22.7.[23]|22.8)
		[ -r checkit.OLD ] || mv checkit checkit.OLD || exit 1
		cat checkit.OLD \
			| sed '/^as86/	s%as%'${FR_TH_ROOT}'/usr/bin/as%' \
			| sed '/^ld86/	s%ld%'${FR_TH_ROOT}'/usr/bin/ld%' \
			| sed '/^bcc/	s%bcc%'${FR_TH_ROOT}'/usr/bin/bcc%' \
			> checkit || exit 1
		chmod 755 checkit || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# BUILD...
	case ${PKGVER} in
	22.7.2-beta6|22.7.[23]|22.8)
		make CC=${FR_HOST_CC} version || exit 1
		make CC=${FR_HOST_CC} mkloader || exit 1
		make lilo || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
#	make ROOT=${INSTTEMP} install || exit 1
	mkdir -p ${INSTTEMP} || exit 1

	BUILTIN=1
	if [ ! -d ${INSTTEMP}/sbin ]; then mkdir ${INSTTEMP}/sbin; fi
	if [ ! -d ${INSTTEMP}/etc ]; then mkdir ${INSTTEMP}/etc; fi
	if [ ! -d ${INSTTEMP}/boot ]; then mkdir ${INSTTEMP}/boot; fi
	if [ ! -d ${INSTTEMP}/usr/sbin ]; then \
	  mkdir -p ${INSTTEMP}/usr/sbin; fi
	if [ ! -d ${INSTTEMP}/man ]; then mkdir ${INSTTEMP}/man; fi  
	if [ ! -d ${INSTTEMP}/man/man5 ]; then \
	  mkdir ${INSTTEMP}/man/man5; fi  
	if [ ! -d ${INSTTEMP}/man/man8 ]; then \
	  mkdir ${INSTTEMP}/man/man8; fi  
	if [ -f diag1.img ]; then \
	  cp -f diag1.img ${INSTTEMP}/boot; fi
	if [ -f diag2.img ]; then \
	  cp -f diag2.img ${INSTTEMP}/boot; fi
	if [ ! -L ${INSTTEMP}/boot/boot.b -a -f ${INSTTEMP}/boot/boot.b ]; then \
	  mv ${INSTTEMP}/boot/boot.b ${INSTTEMP}/boot/boot.old; fi
	if [ -f ${INSTTEMP}/boot/boot-bmp.b ]; then \
	  mv ${INSTTEMP}/boot/boot-bmp.b ${INSTTEMP}/boot/boot-bmp.old; fi
	if [ -f ${INSTTEMP}/boot/boot-menu.b ]; then \
	  mv ${INSTTEMP}/boot/boot-menu.b ${INSTTEMP}/boot/boot-menu.old; fi
	if [ -f ${INSTTEMP}/boot/boot-text.b ]; then \
	  mv ${INSTTEMP}/boot/boot-text.b ${INSTTEMP}/boot/boot-text.old; fi
	if [ -f ${INSTTEMP}/boot/chain.b ]; then \
	  mv ${INSTTEMP}/boot/chain.b ${INSTTEMP}/boot/chain.old; fi
	if [ -f ${INSTTEMP}/boot/os2_d.b ]; then \
	  mv ${INSTTEMP}/boot/os2_d.b ${INSTTEMP}/boot/os2_d.old; fi
	if [ -f ${INSTTEMP}/boot/mbr.b ]; then \
	  mv ${INSTTEMP}/boot/mbr.b ${INSTTEMP}/boot/mbr.old; fi
	if [ -f os2_d.b  -a  ${BUILTIN} = 0 ]; then \
	  cp os2_d.b ${INSTTEMP}/boot; fi
	if [ ${BUILTIN} = 0 ]; then \
	  cp boot-text.b boot-menu.b boot-bmp.b chain.b mbr.b ${INSTTEMP}/boot; fi
	if [ ! -L ${INSTTEMP}/boot/boot.b  -a  ${BUILTIN} = 0 ]; then \
	  ln -s boot-menu.b ${INSTTEMP}/boot/boot.b; fi
	if [ ${BUILTIN} = 1 ]; then \
	  rm -f ${INSTTEMP}/boot/boot.b; fi
	cp mkrescue ${INSTTEMP}/sbin
	cp lilo ${INSTTEMP}/sbin
	strip ${INSTTEMP}/sbin/lilo
	cp keytab-lilo.pl ${INSTTEMP}/usr/sbin
	cp manPages/lilo.8 ${INSTTEMP}/man/man8
	cp manPages/mkrescue.8 ${INSTTEMP}/man/man8
	cp manPages/lilo.conf.5 ${INSTTEMP}/man/man5
	if [ -e ${INSTTEMP}/etc/lilo/install ]; then echo; \
	  echo -n "${INSTTEMP}/etc/lilo/install is obsolete. LILO is now ";\
	  echo "re-installed "; \
	  echo "by just invoking /sbin/lilo"; echo; fi
	echo "/sbin/lilo must now be run to complete the update."
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
