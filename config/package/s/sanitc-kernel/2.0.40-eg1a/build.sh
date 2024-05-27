#!/bin/sh
# 21/05/2007

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_modify_config()
{
	while [ "$1" ] ; do
		NAME=`echo $1 | sed 's/^_/CONFIG_/'`
		shift
		VALUE=$1
		shift

		cat .config \
			| sed "s%^[# ]*${NAME}[= ].*%#[${NAME} adjusted]%" \
			> tmp.$$ || exit 1
		mv tmp.$$ .config
		case ${VALUE} in
		#*)		;;	## ...ignore
		unset|UNSET)	echo "# ${NAME} is not set" >> .config ;;
		*)		echo "${NAME}=${VALUE}" >> .config ;;
		esac
	done
}

modify_config()
{
	mkdir -p ${TCTREE}/etc/${USE_DISTRO} || exit 1

	do_modify_config _EXPERIMENTAL y \
		_MODULES y	_MODVERSIONS unset	_KERNELD y \
		_MATH_EMULATION y \
		_MEM_STD y	_MEM_ENT unset	_MEM_SPECIAL unset \
		_MAX_MEMSIZE 1024 \
		\
		_NET y	_MAX_16M unset	_PCI y	_SYSVIPC unset \
		_BINFMT_AOUT y	_BINFMT_ELF y	_KERNEL_ELF y \
			_BINFMT_JAVA unset \
		_M386 y	_M486 unset	_M586 unset	_M686 unset \
		_APM y	_APM_CPU_IDLE y \
			_APM_IGNORE_USER_SUSPEND unset \
			_APM_DO_ENABLE unset \
			_APM_DISPLAY_BLANK y	_APM_POWER_OFF y \
			_APM_IGNORE_MULTIPLE_SUSPEND unset \
		\
		_BLK_DEV_FD y	_BLK_DEV_IDE y \
		_BLK_DEV_HD_IDE unset	_BLK_DEV_IDECD y \
		_BLK_DEV_IDETAPE unset	_BLK_DEV_IDEFLOPPY unset \
		_BLK_DEV_IDESCSI unset	_BLK_DEV_IDE_PCMCIA y \
		_BLK_DEV_CMD640 y	_BLK_DEV_CMD640_ENHANCED unset \
		_BLK_DEV_RZ1000 y	_BLK_DEV_TRITON y \
		_BLK_DEV_OFFBOARD unset	_IDE_CHIPSETS unset \
		_BLK_DEV_LOOP m \
		_BLK_DEV_MD y	_MD_LINEAR m	_MD_STRIPED m \
			_MD_MIRRORING m	_MD_RAID5 m \
		_BLK_DEV_RAM y	_BLK_DEV_INITRD y \
		_BLK_DEV_XD unset \
		_BLK_DEV_DAC960 unset	_BLK_CPQ_DA unset \
		_PARIDE m	_PARIDE_PD m	_PARIDE_PCD m	_PARIDE_PF m \
			_PARIDE_PT m	_PARIDE_PG m \
			_PARIDE_ATEN unset	_PARIDE_BPCK m \
			_PARIDE_COMM unset	_PARIDE_DSTR unset \
			_PARIDE_FIT2 unset	_PARIDE_FIT3 unset \
			_PARIDE_EPAT unset	_PARIDE_EPIA unset \
			_PARIDE_FRIQ unset	_PARIDE_FRPW unset \
			_PARIDE_KBIC unset	_PARIDE_KTTI unset \
			_PARIDE_ON20 unset	_PARIDE_ON26 unset \
		_BLK_DEV_HD unset \
		\
		_FIREWALL unset	_BRIDGE unset	_NET_ALIAS unset	_INET y \
		_IP_FORWARD unset	_IP_MULTICAST unset \
		_SYN_COOKIES unset	_IP_ACCT unset	_IP_ROUTER unset \
		_NET_IPIP unset	_INET_PCTCP unset	_INET_RARP unset \
		_NO_PATH_MTU_DISCOVERY unset \
		_IP_NOSR y	_SKB_LARGE y \
		_IPX unset	_ATALK unset	_AX25 unset	_NETLINK unset \
		\
		_SCSI m	_BLK_DEV_SD m	_CHR_DEV_ST m \
			_BLK_DEV_SR m	_CHR_DEV_SG m \
			_SCSI_MULTI_LUN y	_SCSI_CONSTANTS unset \
			_SCSI_7000FASST unset	_SCSI_ACARD unset \
			_SCSI_AHA152X unset	_SCSI_AHA1542 unset \
			_SCSI_AHA1740 unset	_SCSI_AIC7XXX unset \
			_SCSI_ADVANSYS m	_SCSI_IN2000 unset \
			_SCSI_AM53C974 unset	_SCSI_MEGARAID unset \
			_SCSI_BUSLOGIC unset	_SCSI_DTC3280 unset \
			_SCSI_EATA_DMA unset	_SCSI_EATA_PIO unset \
			_SCSI_EATA unset	_SCSI_FUTURE_DOMAIN unset \
			_SCSI_GENERIC_NCR5380 unset \
			_SCSI_INITIO unset	_SCSI_INIA100 unset \
			_SCSI_NCR53C406A unset	_SCSI_SYM53C416 unset \
			_SCSI_NCR53C7xx unset	_SCSI_NCR53C8XX unset \
			_SCSI_PPA m	_SCSI_PPA_HAVE_PEDANTIC y \
			_SCSI_PAS16 unset	_SCSI_PCI2000 unset \
			_SCSI_PCI2220I unset	_SCSI_PSI240I unset \
			_SCSI_QLOGIC_FAS unset \
			_SCSI_QLOGIC_ISP unset \
			_SCSI_SEAGATE unset	_SCSI_DC390T unset \
			_SCSI_T128 unset	_SCSI_TC2550 unset \
			_SCSI_U14_34F unset	_SCSI_ULTRASTOR unset \
			_SCSI_GDTH unset \
		\
		_NETDEVICES y	_DUMMY m \
			_EQUALIZER unset \
			_PLIP unset	_PPP unset \
			_SLIP unset	_NET_RADIO unset \
		_NET_ETHERNET y \
			_NET_VENDOR_3COM y \
			_EL1 unset	_EL2 unset	_EL3 m \
			_EL16 unset	_ELPLUS unset \
			_3C515 unset	_VORTEX m \
			_NET_VENDOR_SMC y \
			_WD80x3 m \
			_ULTRA m	_ULTRA32 m	_SMC9194 m \
		_NET_PCI y	_PCNET32 unset \
			_EEXPRESS_PRO m \
			_EEXPRESS_PRO100B m	_DE4X5 unset \
			_DEC_ELCP unset	_DGRS unset	_NE2K_PCI m \
			_YELLOWFIN unset	_RTL8139 m	_EPIC unset \
			_TLAN unset	_VIA_RHINE unset	_SHAPER unset \
			_ETH16I unset	_FMV18X unset	_ISI unset \
			_NI52 unset	_NI65 unset	_PCI_OPTIMIZE unset \
		_NET_ISA y \
			_LANCE unset	_AT1700 unset	_E2100 unset \
			_DEPCA unset	_EWRK3 unset	_EEXPRESS m \
			_HPLAN_PLUS unset	_HPLAN unset	_HP100 unset \
			_NE2000 m	_SK_G16 unset \
		_NET_EISA unset	_NET_POCKET unset	_TR unset \
			_FDDI unset	_ARCNET unset \
		_ISDN unset	_CD_NO_IDESCSI unset \
		\
		_QUOTA unset	_AUTOFS_FS y \
			_MINIX_FS y	_EXT_FS unset	_EXT2_FS m \
			_XIA_FS unset \
			_NLS y	_NLS_CODEPAGE_437 y \
				_NLS_ISO8859_1 y \
				_NLS_ISO8859_14 m \
				_NLS_ISO8859_15 m \
			_ISO9660_FS y	_FAT_FS y	_MSDOS_FS y \
			_UMSDOS_FS y	_VFAT_FS y \
		_PROC_FS y	_NFS_FS m	_SMB_FS m	_SMB_WIN95 y \
		_HPFS_FS m	_SYSV_FS m \
		_UFS_FS m	_BSD_DISKLABEL y	_SMD_DISKLABEL y \
			_AFFS_FS m	_AMIGA_PARTITION y \
		\
		_SERIAL m	_SERIAL_PCI unset	_DIGI unset	_CYCLADES unset \
			_STALDRV unset	_RISCOM8 unset \
		_PRINTER m	_SPECIALIX unset \
		_MOUSE y \
			_ATIXL_BUSMOUSE m	_BUSMOUSE m \
			_MS_BUSMOUSE m	_PSMOUSE m	_82C710_MOUSE y \
		_UMISC unset	_QIC02_TAPE unset	_FTAPE m \
		_WATCHDOG unset	_RTC unset \
		_SOUND unset	_PAS unset	_SB y	_ADLIB unset \
			_MPU401 unset	_UART6850 unset	_PSS unset \
			_GUS unset	_GUS16 unset	_GUSMAX unset	_MSS unset \
			_SSCAPE unset	_TRIX unset	_MAD16 unset \
			_CS4232 unset	_MAUI unset \
		\
		_AUDIO y	_MIDI y	_LOWLEVEL_SOUND unset \
		_YM3812 Y \
		SBC_BASE 220	SBC_IRQ 7	SBC_DMA 1	SB_DMA2 5 \
			SB_MPU_BASE 0	SB_MPU_IRQ -1 \
			DSP_BUFFSIZE 65536 \
		_DLCI unset	_RCPCI unset	_SEEQ8005 unset \
		_PROFILE unset	_SADISTIC_KMALLOC unset	_SKB_CHECK unset
	#cp .config config-apm || exit 1
	cp .config ${TCTREE}/etc/${USE_DISTRO}/config-lx${PKGVER}-apm || exit 1

	do_modify_config _APM unset \
			_APM_CPU_IDLE unset \
			_APM_IGNORE_USER_SUSPEND unset \
			_APM_DO_ENABLE unset \
			_APM_DISPLAY_BLANK unset \
			_APM_POWER_OFF unset \
			_APM_IGNORE_MULTIPLE_SUSPEND unset
	#cp .config config-noapm || exit 1
	cp .config ${TCTREE}/etc/${USE_DISTRO}/config-lx${PKGVER}-noapm || exit 1
}

make_th()
{
# CONFIGURE...
	# sanitc 27/06/2005+
	if [ -d ${INSTTEMP}/host-utils ] ; then
		FR_TH_ROOT=${INSTTEMP}/host-utils
	else
		FR_TH_ROOT=${INSTTEMP}
	fi
	if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
		FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi

	if [ -d ${INSTTEMP}/cross-utils ] ; then
		FR_TC_ROOT=${INSTTEMP}/cross-utils
	else
		FR_TC_ROOT=${INSTTEMP}/
	fi

	case ${PKGVER} in
	2.0.x)	FR_KERNSRC=${FR_TC_ROOT}/src/linux-2.0.40
	;;
	*)
#		if [ -d ${FR_TC_ROOT}/src/linux-${PKGVER} ] ; then
#			FR_KERNSRC=${FR_TC_ROOT}/src/linux-${PKGVER}
#		else
			FR_KERNSRC=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc/src/linux-${PKGVER}
#		fi
	;;
	esac

	if [ ! -d ${FR_KERNSRC} ] ; then
		echo "No KTREE ${FR_KERNSRC} (linux-${PKGVER})" 1>&2
		exit 1
	else
		( cd ${FR_KERNSRC} >/dev/null || exit 1
			tar cvf - include/linux/autoconf.h
		) | tar xvf -
	fi

	if [ ! -d ${TCTREE}/etc/${USE_DISTRO} ] ; then
		echo "No ${TCTREE}/etc/${USE_DISTRO}! Did you build linux2.0source?" 1>&2
		exit 1
	fi

	cp arch/${TARGET_CPU}/defconfig .config || exit 1
	modify_config || exit 1

# BUILD/INSTALL...
	for TWEAK in apm noapm ; do
		CONFIG=${TCTREE}/etc/${USE_DISTRO}/config-lx${PKGVER}-${TWEAK}
		[ -r ${CONFIG} ] || CONFIG=${TCTREE}/etc/${USE_DISTRO}/config-lx`echo ${PKGVER} | sed 's/\.//g'`-${TWEAK}

		cp ${CONFIG} .config || exit 1
		( yes "" | make oldconfig ) || exit 1

		rm scripts/mkdep >/dev/null 2>&1
		make HOSTCC=${FR_HOST_CC} dep || exit 1

		if [ -L `which find` ] ; then
			# busybox 'find' won't `make clean`...
			rm -rf `find ./ -name "*.[ao]"`
		else
			make clean || exit 1
		fi

		# need 2.7.2.3 for 2.0.x kernel (but >= 2.95 for others)
		if [ -r ${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-2.7.2.3-gnu-kgcc ] ; then
			COMPILER=${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-2.7.2.3-gnu-kgcc
		else
			# try uClibc's cross-compiler, if we've built it
			COMPILER=${FR_TC_ROOT}/usr/bin/${TARGET_CPU}-linux-gcc
		fi
		if [ ! -r ${COMPILER} ] ; then
			if [ -r /lib/ld-linux.so.1 ] ; then
				# Assume local compiler is old enough ;)
				COMPILER=`which gcc`
			else
				echo "$0: CONFIGURE: no COMPILER ${COMPILER}"
				exit 1
			fi
		fi

		GCCINCDIR=`${COMPILER} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`
		INCLS='-nostdinc -I'`pwd`'/include -I'${GCCINCDIR}
		for TARGET in modules bzImage ; do
			PATH=${FR_TH_ROOT}/bin:${FR_TH_ROOT}/usr/bin:${PATH} \
			  make CC="${COMPILER} -D__KERNEL__ ${INCLS}" \
				CFLAGS="-O2 -fomit-frame-pointer" \
				${TARGET} || exit 1
		done

		cp arch/${TARGET_CPU}/boot/bzImage ${TCTREE}/etc/${USE_DISTRO}/vmlinuz-${PKGVER}-${TWEAK} || exit 1

		# persuade `make modules_install` into dir?
		mkdir -p ${TCTREE}/etc/${USE_DISTRO}/modules/${PKGVER}-${TWEAK} || exit 1
		#( cd drivers >/dev/null && tar cvf - */*.o ) | ( cd ${TCTREE}/etc/${USE_DISTRO}/modules/${PKGVER}-${TWEAK} && tar xvf - )
		for F in BLOCK FS NET_MISC NET PARIDE SCSI ; do
			LISTFILE=${F}_MODULES
			TARGETDIR=`echo ${F} | tr A-Z a-z | sed 's%_%/%'`
			( cd modules >/dev/null && tar cvf - -h `cat ${LISTFILE}` ) |
				( cd ${TCTREE}/etc/${USE_DISTRO}/modules/${PKGVER}-${TWEAK} >/dev/null || exit 1
				mkdir ${TARGETDIR} 2>/dev/null
				cd ${TARGETDIR} || exit 1
				tar xvf - )
		done
	done
}

case "$1" in
#distro-cross)
#	make_build || exit 1
#;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
;;
*)
	echo "$0: Bad COMMAND $1" 1>&2
	exit 1
;;
esac
