#!/bin/sh
# 2008-10-20

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	if [ -r ${FR_TH_ROOT}/usr/bin/nasm ] ; then
		FR_NASM=${FR_TH_ROOT}/usr/bin/nasm
	else
		echo "$0: Aborting: No 'nasm' built" 1>&2
		exit 1
	fi

	if [ ! -r ${FR_TH_ROOT}/usr/bin/mattrib ] ; then
		echo "$0: Aborting -- no 'mattrib' (from mtools) found" 1>&2
		exit 1
	fi

	case ${PHASE}-${PKGVER} in
	dc-2.1?)
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^NASM/	s%nasm%'${FR_NASM}'%' \
				| sed 's/copybs.com //' \
				| sed 's/syslinux.com //' \
				| sed 's/syslinux.exe //' \
				| sed 's/-D_FILE_OFFSET_BITS=64//' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
	;;
	th-2.1?)
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^NASM/	s%nasm%'${FR_NASM}'%' \
				| sed 's/copybs.com //' \
				| sed 's/syslinux.com //' \
				| sed 's/syslinux.exe //' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CC/	s/= gcc/= ${CCPREFIX}cc/' \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
	;;
	dc-3.6[23])
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s%g*cc%'${FR_CROSS_CC}'%' \
				| sed '/^CFLAGS/ s/-D_FILE_OFFSET_BITS=64//' \
				| sed '/^NASM/	s%nasm%'${FR_NASM}'%' \
				| sed '/^	/ s/-Wp,.*.d //' \
				| sed '/^install:/	s/installer//' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			> com32/lib/MCONFIG || exit 1
	;;
	th-3.6[23])
		find ./ -name Makefile | while read MF ; do
			[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
			cat ${MF}.OLD \
				| sed '/^CC/	s%g*cc%'${FR_HOST_CC}'%' \
				| sed '/^NASM/	s%nasm%'${FR_NASM}'%' \
				| sed '/^	/ s/-Wp,.*.d //' \
				| sed '/^OPTFLAGS/ { s/-falign-functions=0// ; s/-falign-jumps=0// ; s/-falign-loops=0// }' \
				> ${MF} || exit 1
		done

		[ -r com32/lib/MCONFIG.OLD ] || mv com32/lib/MCONFIG com32/lib/MCONFIG.OLD || exit 1
		cat com32/lib/MCONFIG.OLD \
			| sed '/^CFLAGS/ s/-Wp,.*.d //' \
			| sed '/^OPTFLAGS/,+2 { s/-falign-functions=0// ; s/-falign-jumps=0// ; s/-falign-labels=0// }' \
			> com32/lib/MCONFIG || exit 1

		for SF in memdump/string.h dos/string.h ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed 's/_Bool/int/' \
				> ${SF} || exit 1
		done
	;;
	*)
		echo "$0: do_configure() Makefiles adjust: Unexpected PHASE ${PHASE}, PKGVER ${PKGVER}" 1>&2
		exit 1
	esac

# Source files adjust:
	if [ "${PHASE}" = 'dc' ] ; then
		case ${PKGVER} in
		2.1?)
			[ -r syslinux-nomtools.c.OLD ] || mv syslinux-nomtools.c syslinux-nomtools.c.OLD || exit 1
			cat syslinux-nomtools.c.OLD \
				| sed 's%#define _LARGEFILE64_SOURCE.*%//#define _LARGEFILE64_SOURCE...%' \
				| sed 's%|O_LARGEFILE%/* | O_LARGEFILE */%' \
				> syslinux-nomtools.c || exit 1
		;;
		3.6[23])
			[ -r unix/syslinux.c.OLD ] || mv unix/syslinux.c unix/syslinux.c.OLD || exit 1
			cat unix/syslinux.c.OLD \
				| sed '/define _FILE_OFFSET_BITS/ { s%^%/* % ; s%$% */% }' \
				> unix/syslinux.c || exit 1
		;;
		*)
			echo "$0: do_configure() source adjust: Unexpected PHASE ${PHASE}, PKGVER ${PKGVER}" 1>&2
			exit 1
		esac
	fi
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	2.*)
		make CCPREFIX=`echo ${FR_CROSS_CC} | sed 's/cc$//'` \
			  all || exit 1
	;;
	3.6[23])
#	# 2007-12-16: full `make` barfs at memdump compile options
#		make || exit 1
	# 2007-12-16: 'make -C unix syslinux' wants bootsect_bin.o
		make ldlinux_bin.o bootsect_bin.o || exit 1
		make -C unix gethostip lss16toppm ppmtolss16 syslinux || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	2.13)
		mkdir -p ${INSTTEMP}/usr/bin || exit 1
		mkdir -p ${INSTTEMP}/usr/lib/syslinux || exit 1

		cp gethostip lss16toppm ppmtolss16 syslinux ${INSTTEMP}/usr/bin/ || exit 1
		cp memdisk/memdisk ${INSTTEMP}/usr/lib/syslinux/ || exit 1
		cp isolinux.bin ${INSTTEMP}/usr/lib/syslinux/ || exit 1
		cp mbr.bin ${INSTTEMP}/usr/lib/syslinux/ || exit 1
	;;
	3.6[23])
		mkdir -p ${INSTTEMP}/usr/bin || exit 1
		mkdir -p ${INSTTEMP}/usr/lib/syslinux || exit 1

		cp gethostip lss16toppm ppmtolss16 unix/syslinux ${INSTTEMP}/usr/bin/ || exit 1
		cp mbr/mbr.bin ${INSTTEMP}/usr/lib/syslinux/ || exit 1
		cp isolinux.bin ${INSTTEMP}/usr/lib/syslinux/ || exit 1
	;;
	*)	echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

make_th()
{
# CONFIGURE...
	PHASE=th . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=th do_configure || exit 1

# BUILD...
	case ${PKGVER} in
	2.*)
		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
			make CC=${FR_HOST_CC} all || exit 1
	;;
#	3.*)
#		PATH=${FR_TH_ROOT}/usr/bin:${PATH} \
#			installer || exit 1
#	;;
	3.6[23])
		make -C unix syslinux || exit 1
	;;
	*)	echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	2.13)
		mkdir -p ${FR_TH_ROOT}/usr/bin || exit 1
		mkdir -p ${FR_TH_ROOT}/usr/lib/syslinux || exit 1

		cp gethostip lss16toppm ppmtolss16 syslinux ${FR_TH_ROOT}/usr/bin/ || exit 1
		cp isolinux.bin ${FR_TH_ROOT}/usr/lib/syslinux/ || exit 1
		cp mbr.bin ${FR_TH_ROOT}/usr/lib/syslinux/ || exit 1
	;;
	3.6[23])
		mkdir -p ${FR_TH_ROOT}/usr/bin || exit 1
		mkdir -p ${FR_TH_ROOT}/usr/lib/syslinux || exit 1

		cp gethostip lss16toppm ppmtolss16 unix/syslinux ${FR_TH_ROOT}/usr/bin/ || exit 1
		cp mbr/mbr.bin ${FR_TH_ROOT}/usr/lib/syslinux/ || exit 1
		cp isolinux.bin ${FR_TH_ROOT}/usr/lib/syslinux/ || exit 1
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
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
