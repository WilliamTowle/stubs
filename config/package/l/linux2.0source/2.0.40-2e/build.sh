#!/bin/sh
# 29/10/2005

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
			_TLAN unset	_VIA_RHINE m	_SHAPER unset \
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
	cp .config ${TCTREE}/etc/${USE_DISTRO}/config-lx2040-apm || exit 1

	do_modify_config _APM unset \
			_APM_CPU_IDLE unset \
			_APM_IGNORE_USER_SUSPEND unset \
			_APM_DO_ENABLE unset \
			_APM_DISPLAY_BLANK unset \
			_APM_POWER_OFF unset \
			_APM_IGNORE_MULTIPLE_SUSPEND unset
	#cp .config config-noapm || exit 1
	cp .config ${TCTREE}/etc/${USE_DISTRO}/config-lx2040-noapm || exit 1
}

make_dc()
{
# CONFIGURE...

#	case $0 in
#	/*)	SELF=$0 ;;
#	*)	SELF=`pwd`/$0 ;;
#	esac
#
#	# ...2.0.40-rc6 patch still thinks it's 2.0.40-rc5
#	if [ "$PKGVER" = '2.0.40-rc6' ] ; then
#		[ -r Makefile.OLD ] || cp Makefile Makefile.OLD || exit 1
#		 sed 's/^EXTRAVERSION.*rc5/EXTRAVERSION=-rc6/' Makefile.OLD > Makefile || exit 1
#	fi || exit 1

# BUILD...
	make mrproper || exit 1
	[ "CPU${TARGET_CPU}" = 'CPU' ] && exit 1
	( cd include && rm ./asm 2>/dev/null )
	make symlinks || exit 1
	make include/linux/version.h || exit 1
	touch include/linux/autoconf.h || exit 1
##	#if [ ! -r .config ] ; then
##		grep '^#2.0#' $SELF | sed 's/#2.0#	//' > .config
#		cp arch/${TARGET_CPU}/defconfig .config || exit 1
#		modify_config
##	#fi

# INSTALL...

#	mkdir -p ${INSTTEMP}/usr/src || exit 1
#	( cd ${INSTTEMP}/usr/src/ &&
#		[ -d linux-${PKGVER} ] || mkdir linux-${PKGVER}
#		[ -L linux ] && rm ./linux
#		ln -s linux-${PKGVER} linux
#	) || exit 1
#	tar cvf - * .[a-z]* \
#		| ( cd ${INSTTEMP}/usr/src/linux-${PKGVER} && tar xvf - )
	mkdir -p ${INSTTEMP}/usr/include || exit 1
	( cd include &&
		rm -rf *-${PKGVER}
		tar cvf - linux/* asm/* \
			| ( cd ${INSTTEMP}/usr/include && tar xvf - )
	) || exit 1
	( cd ${INSTTEMP}/usr/include &&
		mv linux linux-${PKGVER} &&
		ln -s linux-${PKGVER} linux &&
		mv asm asm-${PKGVER} &&
		ln -s asm-${PKGVER} asm
	) || exit 1
}

make_th()
{
# CONFIGURE...
	if [ ! -d "${TCTREE}" ] ; then
		echo "No TCTREE ${TCTREE}" 1>&2
		exit 1
	fi

	case $0 in
	/*)	SELF=$0 ;;
	*)	SELF=`pwd`/$0 ;;
	esac

	# ...2.0.40-rc6 patch still thinks it's 2.0.40-rc5
	if [ "$PKGVER" = '2.0.40-rc6' ] ; then
		[ -r Makefile.OLD ] || cp Makefile Makefile.OLD || exit 1
		 sed 's/^EXTRAVERSION.*rc5/EXTRAVERSION=-rc6/' Makefile.OLD > Makefile || exit 1
	fi || exit 1

# BUILD...
	make mrproper || exit 1
	[ "CPU${TARGET_CPU}" = 'CPU' ] && exit 1
	( cd include && rm ./asm 2>/dev/null )
	make symlinks || exit 1
	make include/linux/version.h || exit 1
	touch include/linux/autoconf.h || exit 1
#	#if [ ! -r .config ] ; then
#		grep '^#2.0#' $SELF | sed 's/#2.0#	//' > .config
		cp arch/${TARGET_CPU}/defconfig .config || exit 1
		modify_config
#	#fi

	mkdir -p ${TCTREE}/usr/src || exit 1
	( cd ${TCTREE}/usr/src/ &&
		[ -d linux-${PKGVER} ] || mkdir linux-${PKGVER}
		[ -L linux ] && rm ./linux
		ln -s linux-${PKGVER} linux
	) || exit 1
	tar cvf - * .[a-z]* \
		| ( cd ${TCTREE}/usr/src/linux-${PKGVER} && tar xvf - )

	mkdir -p ${INSTTEMP}/usr/include || exit 1
	( cd ${INSTTEMP}/usr/src/linux/include/asm-i386 || exit 1
		mv string.h string.h.OLD || exit 1
		cat string.h.OLD \
			| sed '/^	*rep/	s/rep/"rep/' \
			| sed '/^	*jnz/	s/jnz/"jnz/' \
			| sed '/^	*dec/	s/dec/"dec/' \
			| sed '/^1:/		s/1/"1/' \
			| sed '/^[^"]*"[^"]*$/	s/$/\\n"/' \
			> string.h || exit 1
	) || exit 1
	( cd ${INSTTEMP}/usr/src/linux/include && tar cvf - linux asm* ) | ( cd ${INSTTEMP}/usr/include && tar xvf - )
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#native-build)
#	INSTTEMP=/ make_th || exit 1
#	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Bad COMMAND $1" 1>&2
	exit 1
	;;
esac

##-2.0#	#
##-2.0#	# Automatically generated by make menuconfig: don't edit
##-2.0#	#
##-2.0#	
##-2.0#	#
##-2.0#	# Code maturity level options
##-2.0#	#
##-2.0#	CONFIG_EXPERIMENTAL=y
##-2.0#	
##-2.0#	#
##-2.0#	# Loadable module support
##-2.0#	#
##-2.0#	CONFIG_MODULES=y
##-2.0#	# CONFIG_MODVERSIONS is not set
##-2.0#	CONFIG_KERNELD=y
##-2.0#	
##-2.0#	#
##-2.0#	# General setup
##-2.0#	#
##-2.0#	CONFIG_MATH_EMULATION=y
##-2.0#	CONFIG_MEM_STD=y
##-2.0#	# CONFIG_MEM_ENT is not set
##-2.0#	# CONFIG_MEM_SPECIAL is not set
##-2.0#	CONFIG_MAX_MEMSIZE=1024
##-2.0#	CONFIG_NET=y
##-2.0#	# CONFIG_MAX_16M is not set
##-2.0#	CONFIG_PCI=y
##-2.0#	# CONFIG_PCI_OPTIMIZE is not set
##-2.0#	# CONFIG_SYSVIPC is not set
##-2.0#	CONFIG_BINFMT_AOUT=y
##-2.0#	CONFIG_BINFMT_ELF=y
##-2.0#	# CONFIG_BINFMT_JAVA is not set
##-2.0#	CONFIG_KERNEL_ELF=y
##-2.0#	CONFIG_M386=y
##-2.0#	# CONFIG_M486 is not set
##-2.0#	# CONFIG_M586 is not set
##-2.0#	# CONFIG_M686 is not set
##-2.0#	# CONFIG_APM is not set
##-2.0#	
##-2.0#	#
##-2.0#	# Floppy, IDE, and other block devices
##-2.0#	#
##-2.0#	CONFIG_BLK_DEV_FD=y
##-2.0#	CONFIG_BLK_DEV_IDE=y
##-2.0#	# CONFIG_BLK_DEV_HD_IDE is not set
##-2.0#	CONFIG_BLK_DEV_IDECD=y
##-2.0#	# CONFIG_BLK_DEV_IDETAPE is not set
##-2.0#	# CONFIG_BLK_DEV_IDEFLOPPY is not set
##-2.0## CONFIG_BLK_DEV_IDESCSI is not set
##-2.0#	CONFIG_BLK_DEV_IDE_PCMCIA=y
##-2.0#	CONFIG_BLK_DEV_CMD640=y
##-2.0#	# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
##-2.0#	CONFIG_BLK_DEV_RZ1000=y
##-2.0#	CONFIG_BLK_DEV_TRITON=y
##-2.0#	# CONFIG_BLK_DEV_OFFBOARD is not set
##-2.0#	# CONFIG_IDE_CHIPSETS is not set
##-2.0#	CONFIG_BLK_DEV_LOOP=m
##-2.0#	CONFIG_BLK_DEV_MD=y
##-2.0#	CONFIG_MD_LINEAR=m
##-2.0#	CONFIG_MD_STRIPED=m
##-2.0#	CONFIG_MD_MIRRORING=m
##-2.0#	CONFIG_MD_RAID5=m
##-2.0#	CONFIG_BLK_DEV_RAM=y
##-2.0#	CONFIG_BLK_DEV_INITRD=y
##-2.0#	# CONFIG_BLK_DEV_XD is not set
##-2.0#	# CONFIG_BLK_DEV_DAC960 is not set
##-2.0#	# CONFIG_BLK_CPQ_DA is not set
##-2.0#	CONFIG_PARIDE=m
##-2.0#	CONFIG_PARIDE_PD=m
##-2.0#	CONFIG_PARIDE_PCD=m
##-2.0#	CONFIG_PARIDE_PF=m
##-2.0#	CONFIG_PARIDE_PT=m
##-2.0#	CONFIG_PARIDE_PG=m
##-2.0#	# CONFIG_PARIDE_ATEN is not set
##-2.0#	CONFIG_PARIDE_BPCK=m
##-2.0#	# CONFIG_PARIDE_COMM is not set
##-2.0#	# CONFIG_PARIDE_DSTR is not set
##-2.0#	# CONFIG_PARIDE_FIT2 is not set
##-2.0#	# CONFIG_PARIDE_FIT3 is not set
##-2.0#	# CONFIG_PARIDE_EPAT is not set
##-2.0#	# CONFIG_PARIDE_EPIA is not set
##-2.0#	# CONFIG_PARIDE_FRIQ is not set
##-2.0#	# CONFIG_PARIDE_FRPW is not set
##-2.0#	# CONFIG_PARIDE_KBIC is not set
##-2.0#	# CONFIG_PARIDE_KTTI is not set
##-2.0#	# CONFIG_PARIDE_ON20 is not set
##-2.0#	# CONFIG_PARIDE_ON26 is not set
##-2.0#	# CONFIG_BLK_DEV_HD is not set
##-2.0#	
##-2.0#	#
##-2.0#	# Networking options
##-2.0#	#
##-2.0#	# CONFIG_FIREWALL is not set
##-2.0#	# CONFIG_NET_ALIAS is not set
##-2.0#	CONFIG_INET=y
##-2.0#	# CONFIG_IP_FORWARD is not set
##-2.0#	# CONFIG_IP_MULTICAST is not set
##-2.0#	# CONFIG_SYN_COOKIES is not set
##-2.0#	# CONFIG_IP_ACCT is not set
##-2.0#	# CONFIG_IP_ROUTER is not set
##-2.0#	# CONFIG_NET_IPIP is not set
##-2.0#	# CONFIG_INET_PCTCP is not set
##-2.0#	# CONFIG_INET_RARP is not set
##-2.0#	# CONFIG_NO_PATH_MTU_DISCOVERY is not set
##-2.0#	CONFIG_IP_NOSR=y
##-2.0#	CONFIG_SKB_LARGE=y
##-2.0#	# CONFIG_IPX is not set
##-2.0#	# CONFIG_ATALK is not set
##-2.0#	# CONFIG_AX25 is not set
##-2.0#	# CONFIG_BRIDGE is not set
##-2.0#	# CONFIG_NETLINK is not set
##-2.0#	
##-2.0#	#
##-2.0#	# SCSI support
##-2.0#	#
##-2.0#CONFIG_SCSI=m
##-2.0#CONFIG_BLK_DEV_SD=m
##-2.0#CONFIG_CHR_DEV_ST=m
##-2.0#CONFIG_BLK_DEV_SR=m
##-2.0#CONFIG_CHR_DEV_SG=m
##-2.0#CONFIG_SCSI_MULTI_LUN=y
##-2.0#CONFIG_SCSI_CONSTANTS=y
##-2.0#	
##-2.0#	#
##-2.0#	# SCSI low-level drivers
##-2.0#	#
##-2.0#	# CONFIG_SCSI_7000FASST is not set
##-2.0#	# CONFIG_SCSI_ACARD is not set
##-2.0#	# CONFIG_SCSI_AHA152X is not set
##-2.0#	# CONFIG_SCSI_AHA1542 is not set
##-2.0#	# CONFIG_SCSI_AHA1740 is not set
##-2.0#	# CONFIG_SCSI_AIC7XXX is not set
##-2.0#CONFIG_SCSI_ADVANSYS=m
##-2.0#	# CONFIG_SCSI_IN2000 is not set
##-2.0#	# CONFIG_SCSI_AM53C974 is not set
##-2.0#	# CONFIG_SCSI_MEGARAID is not set
##-2.0#	# CONFIG_SCSI_BUSLOGIC is not set
##-2.0#	# CONFIG_SCSI_DTC3280 is not set
##-2.0#	# CONFIG_SCSI_EATA_DMA is not set
##-2.0#	# CONFIG_SCSI_EATA_PIO is not set
##-2.0#	# CONFIG_SCSI_EATA is not set
##-2.0#	# CONFIG_SCSI_FUTURE_DOMAIN is not set
##-2.0#	# CONFIG_SCSI_GENERIC_NCR5380 is not set
##-2.0#	# CONFIG_SCSI_INITIO is not set
##-2.0#	# CONFIG_SCSI_INIA100 is not set
##-2.0#	# CONFIG_SCSI_NCR53C406A is not set
##-2.0#	# CONFIG_SCSI_SYM53C416 is not set
##-2.0#	# CONFIG_SCSI_NCR53C7xx is not set
##-2.0#	# CONFIG_SCSI_NCR53C8XX is not set
##-2.0#CONFIG_SCSI_PPA=m
##-2.0#CONFIG_SCSI_PPA_HAVE_PEDANTIC=y
##-2.0#	# CONFIG_SCSI_PAS16 is not set
##-2.0#	# CONFIG_SCSI_PCI2000 is not set
##-2.0#	# CONFIG_SCSI_PCI2220I is not set
##-2.0#	# CONFIG_SCSI_PSI240I is not set
##-2.0#	# CONFIG_SCSI_QLOGIC_FAS is not set
##-2.0#	# CONFIG_SCSI_QLOGIC_ISP is not set
##-2.0#	# CONFIG_SCSI_SEAGATE is not set
##-2.0#	# CONFIG_SCSI_DC390T is not set
##-2.0#	# CONFIG_SCSI_T128 is not set
##-2.0#	# CONFIG_SCSI_TC2550 is not set
##-2.0#	# CONFIG_SCSI_U14_34F is not set
##-2.0#	# CONFIG_SCSI_ULTRASTOR is not set
##-2.0#	# CONFIG_SCSI_GDTH is not set
##-2.0#	
##-2.0#	#
##-2.0#	# Network device support
##-2.0#	#
##-2.0#	CONFIG_NETDEVICES=y
##-2.0#	CONFIG_DUMMY=m
##-2.0#	# CONFIG_EQUALIZER is not set
##-2.0#	# CONFIG_DLCI is not set
##-2.0#	# CONFIG_PLIP is not set
##-2.0#	# CONFIG_PPP is not set
##-2.0#	# CONFIG_SLIP is not set
##-2.0#	# CONFIG_NET_RADIO is not set
##-2.0#	CONFIG_NET_ETHERNET=y
##-2.0#	CONFIG_NET_VENDOR_3COM=y
##-2.0#	# CONFIG_EL1 is not set
##-2.0#	# CONFIG_EL2 is not set
##-2.0#	# CONFIG_ELPLUS is not set
##-2.0#	# CONFIG_EL16 is not set
##-2.0#	CONFIG_EL3=m
##-2.0#	# CONFIG_3C515 is not set
##-2.0#	CONFIG_VORTEX=m
##-2.0#	CONFIG_NET_VENDOR_SMC=y
##-2.0#	CONFIG_WD80x3=m
##-2.0#	CONFIG_ULTRA=m
##-2.0#	CONFIG_ULTRA32=m
##-2.0#	CONFIG_SMC9194=m
##-2.0#	CONFIG_NET_PCI=y
##-2.0#	# CONFIG_PCNET32 is not set
##-2.0#	CONFIG_EEXPRESS_PRO100B=m
##-2.0#	# CONFIG_DE4X5 is not set
##-2.0#	# CONFIG_DEC_ELCP is not set
##-2.0#	# CONFIG_DGRS is not set
##-2.0#	CONFIG_NE2K_PCI=m
##-2.0#	# CONFIG_YELLOWFIN is not set
##-2.0#	CONFIG_RTL8139=m
##-2.0#	# CONFIG_EPIC is not set
##-2.0#	# CONFIG_TLAN is not set
##-2.0#	# CONFIG_VIA_RHINE is not set
##-2.0#	CONFIG_NET_ISA=y
##-2.0#	# CONFIG_LANCE is not set
##-2.0#	# CONFIG_AT1700 is not set
##-2.0#	# CONFIG_E2100 is not set
##-2.0#	# CONFIG_DEPCA is not set
##-2.0#	# CONFIG_EWRK3 is not set
##-2.0#	CONFIG_EEXPRESS=m
##-2.0#	CONFIG_EEXPRESS_PRO=m
##-2.0#	# CONFIG_FMV18X is not set
##-2.0#	# CONFIG_HPLAN_PLUS is not set
##-2.0#	# CONFIG_HPLAN is not set
##-2.0#	# CONFIG_HP100 is not set
##-2.0#	# CONFIG_ETH16I is not set
##-2.0#	CONFIG_NE2000=m
##-2.0#	# CONFIG_NI52 is not set
##-2.0#	# CONFIG_NI65 is not set
##-2.0#	# CONFIG_SEEQ8005 is not set
##-2.0#	# CONFIG_SK_G16 is not set
##-2.0#	# CONFIG_NET_EISA is not set
##-2.0#	# CONFIG_NET_POCKET is not set
##-2.0#	# CONFIG_TR is not set
##-2.0#	# CONFIG_FDDI is not set
##-2.0#	# CONFIG_ARCNET is not set
##-2.0#	# CONFIG_SHAPER is not set
##-2.0#	# CONFIG_RCPCI is not set
##-2.0#	
##-2.0#	#
##-2.0#	# ISDN subsystem
##-2.0#	#
##-2.0#	# CONFIG_ISDN is not set
##-2.0#	
##-2.0#	#
##-2.0#	# CD-ROM drivers (not for SCSI or IDE/ATAPI drives)
##-2.0#	#
##-2.0#	# CONFIG_CD_NO_IDESCSI is not set
##-2.0#	
##-2.0#	#
##-2.0#	# Filesystems
##-2.0#	#
##-2.0#	# CONFIG_QUOTA is not set
##-2.0#	CONFIG_MINIX_FS=y
##-2.0#	# CONFIG_EXT_FS is not set
##-2.0#	CONFIG_EXT2_FS=m
##-2.0#	# CONFIG_XIA_FS is not set
##-2.0#	CONFIG_NLS=y
##-2.0#	CONFIG_ISO9660_FS=y
##-2.0#	CONFIG_FAT_FS=y
##-2.0#	CONFIG_MSDOS_FS=y
##-2.0#	CONFIG_UMSDOS_FS=y
##-2.0#	CONFIG_VFAT_FS=y
##-2.0#	
##-2.0#	#
##-2.0#	# Select available code pages
##-2.0#	#
##-2.0#	CONFIG_NLS_CODEPAGE_437=y
##-2.0#	# CONFIG_NLS_CODEPAGE_737 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_775 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_850 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_852 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_855 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_857 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_860 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_861 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_862 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_863 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_864 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_865 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_866 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_869 is not set
##-2.0#	# CONFIG_NLS_CODEPAGE_874 is not set
##-2.0#	CONFIG_NLS_ISO8859_1=y
##-2.0#	# CONFIG_NLS_ISO8859_2 is not set
##-2.0#	# CONFIG_NLS_ISO8859_3 is not set
##-2.0#	# CONFIG_NLS_ISO8859_4 is not set
##-2.0#	# CONFIG_NLS_ISO8859_5 is not set
##-2.0#	# CONFIG_NLS_ISO8859_6 is not set
##-2.0#	# CONFIG_NLS_ISO8859_7 is not set
##-2.0#	# CONFIG_NLS_ISO8859_8 is not set
##-2.0#	# CONFIG_NLS_ISO8859_9 is not set
##-2.0#	CONFIG_NLS_ISO8859_14=m
##-2.0#	CONFIG_NLS_ISO8859_15=m
##-2.0#	# CONFIG_NLS_KOI8_R is not set
##-2.0#	CONFIG_PROC_FS=y
##-2.0#	CONFIG_NFS_FS=m
##-2.0#	CONFIG_SMB_FS=m
##-2.0#	CONFIG_SMB_WIN95=y
##-2.0#	CONFIG_HPFS_FS=m
##-2.0#	CONFIG_SYSV_FS=m
##-2.0#	CONFIG_AUTOFS_FS=y
##-2.0#	CONFIG_AFFS_FS=m
##-2.0#	CONFIG_AMIGA_PARTITION=y
##-2.0#	CONFIG_UFS_FS=m
##-2.0#	CONFIG_BSD_DISKLABEL=y
##-2.0#	CONFIG_SMD_DISKLABEL=y
##-2.0#	
##-2.0#	#
##-2.0#	# Character devices
##-2.0#	#
##-2.0#	CONFIG_SERIAL=m
##-2.0#	# CONFIG_SERIAL_PCI is not set
##-2.0#	# CONFIG_DIGI is not set
##-2.0#	# CONFIG_CYCLADES is not set
##-2.0#	# CONFIG_ISI is not set
##-2.0#	# CONFIG_STALDRV is not set
##-2.0#	# CONFIG_RISCOM8 is not set
##-2.0#	CONFIG_PRINTER=m
##-2.0#	# CONFIG_SPECIALIX is not set
##-2.0#	CONFIG_MOUSE=y
##-2.0#	CONFIG_ATIXL_BUSMOUSE=m
##-2.0#	CONFIG_BUSMOUSE=m
##-2.0#	CONFIG_MS_BUSMOUSE=m
##-2.0#	CONFIG_PSMOUSE=m
##-2.0#	CONFIG_82C710_MOUSE=y
##-2.0#	# CONFIG_UMISC is not set
##-2.0#	# CONFIG_QIC02_TAPE is not set
##-2.0#	CONFIG_FTAPE=m
##-2.0#	# CONFIG_WATCHDOG is not set
##-2.0#	# CONFIG_RTC is not set
##-2.0#	
##-2.0##
##-2.0## Sound
##-2.0##
##-2.0#CONFIG_SOUND=m
##-2.0## CONFIG_PAS is not set
##-2.0#CONFIG_SB=y
##-2.0#CONFIG_ADLIB=y
##-2.0## CONFIG_GUS is not set
##-2.0## CONFIG_MPU401 is not set
##-2.0## CONFIG_UART6850 is not set
##-2.0## CONFIG_PSS is not set
##-2.0## CONFIG_GUS16 is not set
##-2.0## CONFIG_GUSMAX is not set
##-2.0## CONFIG_MSS is not set
##-2.0## CONFIG_SSCAPE is not set
##-2.0## CONFIG_TRIX is not set
##-2.0## CONFIG_MAD16 is not set
##-2.0## CONFIG_CS4232 is not set
##-2.0## CONFIG_MAUI is not set
##-2.0#CONFIG_YM3812=y
##-2.0#CONFIG_AUDIO=y
##-2.0#CONFIG_MIDI=y
##-2.0#SBC_BASE=220
##-2.0#SBC_IRQ=7
##-2.0#SBC_DMA=1
##-2.0#SB_DMA2=5
##-2.0#SB_MPU_BASE=0
##-2.0#SB_MPU_IRQ=-1
##-2.0#DSP_BUFFSIZE=65536
##-2.0## CONFIG_LOWLEVEL_SOUND is not set
##-2.0#	
##-2.0#	#
##-2.0#	# Kernel hacking
##-2.0#	#
##-2.0#	# CONFIG_PROFILE is not set
##-2.0#	# CONFIG_SADISTIC_KMALLOC is not set
##-2.0#	# CONFIG_SKB_CHECK is not set
#
##2.0#	#
##2.0#	# Automatically generated by make menuconfig: don't edit
##2.0#	#
##2.0#	
##2.0#	#
##2.0#	# Code maturity level options
##2.0#	#
##2.0#	CONFIG_EXPERIMENTAL=y
##2.0#	
##2.0#	#
##2.0#	# Loadable module support
##2.0#	#
##2.0#	CONFIG_MODULES=y
##2.0#	# CONFIG_MODVERSIONS is not set
##2.0#	CONFIG_KERNELD=y
##2.0#	
##2.0#	#
##2.0#	# General setup
##2.0#	#
##2.0#	CONFIG_MATH_EMULATION=y
##2.0#	CONFIG_MEM_STD=y
##2.0#	# CONFIG_MEM_ENT is not set
##2.0#	# CONFIG_MEM_SPECIAL is not set
##2.0#	CONFIG_MAX_MEMSIZE=1024
##2.0#	CONFIG_NET=y
##2.0#	# CONFIG_MAX_16M is not set
##2.0#	CONFIG_PCI=y
##2.0#	# CONFIG_PCI_OPTIMIZE is not set
##2.0#	# CONFIG_SYSVIPC is not set
##2.0#	CONFIG_BINFMT_AOUT=y
##2.0#	CONFIG_BINFMT_ELF=y
##2.0#	# CONFIG_BINFMT_JAVA is not set
##2.0#	CONFIG_KERNEL_ELF=y
##2.0#	CONFIG_M386=y
##2.0#	# CONFIG_M486 is not set
##2.0#	# CONFIG_M586 is not set
##2.0#	# CONFIG_M686 is not set
##2.0#	# CONFIG_APM is not set
##2.0#	
##2.0#	#
##2.0#	# Floppy, IDE, and other block devices
##2.0#	#
##2.0#	CONFIG_BLK_DEV_FD=y
##2.0#	CONFIG_BLK_DEV_IDE=y
##2.0#	# CONFIG_BLK_DEV_HD_IDE is not set
##2.0#	CONFIG_BLK_DEV_IDECD=y
##2.0#	# CONFIG_BLK_DEV_IDETAPE is not set
##2.0#	# CONFIG_BLK_DEV_IDEFLOPPY is not set
##2.0#	# CONFIG_BLK_DEV_IDESCSI is not set
##2.0#	CONFIG_BLK_DEV_IDE_PCMCIA=y
##2.0#	CONFIG_BLK_DEV_CMD640=y
##2.0#	# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
##2.0#	CONFIG_BLK_DEV_RZ1000=y
##2.0#	CONFIG_BLK_DEV_TRITON=y
##2.0#	# CONFIG_BLK_DEV_OFFBOARD is not set
##2.0#	# CONFIG_IDE_CHIPSETS is not set
##2.0#	CONFIG_BLK_DEV_LOOP=m
##2.0#	CONFIG_BLK_DEV_MD=y
##2.0#	CONFIG_MD_LINEAR=m
##2.0#	CONFIG_MD_STRIPED=m
##2.0#	CONFIG_MD_MIRRORING=m
##2.0#	CONFIG_MD_RAID5=m
##2.0#	CONFIG_BLK_DEV_RAM=y
##2.0#	CONFIG_BLK_DEV_INITRD=y
##2.0#	# CONFIG_BLK_DEV_XD is not set
##2.0#	# CONFIG_BLK_DEV_DAC960 is not set
##2.0#	# CONFIG_BLK_CPQ_DA is not set
##2.0#	CONFIG_PARIDE=m
##2.0#	CONFIG_PARIDE_PD=m
##2.0#	CONFIG_PARIDE_PCD=m
##2.0#	CONFIG_PARIDE_PF=m
##2.0#	CONFIG_PARIDE_PT=m
##2.0#	CONFIG_PARIDE_PG=m
##2.0#	# CONFIG_PARIDE_ATEN is not set
##2.0#	CONFIG_PARIDE_BPCK=m
##2.0#	# CONFIG_PARIDE_COMM is not set
##2.0#	# CONFIG_PARIDE_DSTR is not set
##2.0#	# CONFIG_PARIDE_FIT2 is not set
##2.0#	# CONFIG_PARIDE_FIT3 is not set
##2.0#	# CONFIG_PARIDE_EPAT is not set
##2.0#	# CONFIG_PARIDE_EPIA is not set
##2.0#	# CONFIG_PARIDE_FRIQ is not set
##2.0#	# CONFIG_PARIDE_FRPW is not set
##2.0#	# CONFIG_PARIDE_KBIC is not set
##2.0#	# CONFIG_PARIDE_KTTI is not set
##2.0#	# CONFIG_PARIDE_ON20 is not set
##2.0#	# CONFIG_PARIDE_ON26 is not set
##2.0#	# CONFIG_BLK_DEV_HD is not set
##2.0#	
##2.0#	#
##2.0#	# Networking options
##2.0#	#
##2.0#	# CONFIG_FIREWALL is not set
##2.0#	# CONFIG_NET_ALIAS is not set
##2.0#	CONFIG_INET=y
##2.0#	# CONFIG_IP_FORWARD is not set
##2.0#	# CONFIG_IP_MULTICAST is not set
##2.0#	# CONFIG_SYN_COOKIES is not set
##2.0#	# CONFIG_IP_ACCT is not set
##2.0#	# CONFIG_IP_ROUTER is not set
##2.0#	# CONFIG_NET_IPIP is not set
##2.0#	# CONFIG_INET_PCTCP is not set
##2.0#	# CONFIG_INET_RARP is not set
##2.0#	# CONFIG_NO_PATH_MTU_DISCOVERY is not set
##2.0#	CONFIG_IP_NOSR=y
##2.0#	CONFIG_SKB_LARGE=y
##2.0#	# CONFIG_IPX is not set
##2.0#	# CONFIG_ATALK is not set
##2.0#	# CONFIG_AX25 is not set
##2.0#	# CONFIG_BRIDGE is not set
##2.0#	# CONFIG_NETLINK is not set
##2.0#	
##2.0#	#
##2.0#	# SCSI support
##2.0#	#
##2.0#	# CONFIG_SCSI is not set
##2.0#	
##2.0#	#
##2.0#	# Network device support
##2.0#	#
##2.0#	CONFIG_NETDEVICES=y
##2.0#	CONFIG_DUMMY=m
##2.0#	# CONFIG_EQUALIZER is not set
##2.0#	# CONFIG_DLCI is not set
##2.0#	# CONFIG_PLIP is not set
##2.0#	# CONFIG_PPP is not set
##2.0#	# CONFIG_SLIP is not set
##2.0#	# CONFIG_NET_RADIO is not set
##2.0#	CONFIG_NET_ETHERNET=y
##2.0#	CONFIG_NET_VENDOR_3COM=y
##2.0#	# CONFIG_EL1 is not set
##2.0#	# CONFIG_EL2 is not set
##2.0#	# CONFIG_ELPLUS is not set
##2.0#	# CONFIG_EL16 is not set
##2.0#	CONFIG_EL3=m
##2.0#	# CONFIG_3C515 is not set
##2.0#	CONFIG_VORTEX=m
##2.0#	CONFIG_NET_VENDOR_SMC=y
##2.0#	CONFIG_WD80x3=m
##2.0#	CONFIG_ULTRA=m
##2.0#	CONFIG_ULTRA32=m
##2.0#	CONFIG_SMC9194=m
##2.0#	CONFIG_NET_PCI=y
##2.0#	# CONFIG_PCNET32 is not set
##2.0#	CONFIG_EEXPRESS_PRO100B=m
##2.0#	# CONFIG_DE4X5 is not set
##2.0#	# CONFIG_DEC_ELCP is not set
##2.0#	# CONFIG_DGRS is not set
##2.0#	CONFIG_NE2K_PCI=m
##2.0#	# CONFIG_YELLOWFIN is not set
##2.0#	CONFIG_RTL8139=m
##2.0#	# CONFIG_EPIC is not set
##2.0#	# CONFIG_TLAN is not set
##2.0#	# CONFIG_VIA_RHINE is not set
##2.0#	CONFIG_NET_ISA=y
##2.0#	# CONFIG_LANCE is not set
##2.0#	# CONFIG_AT1700 is not set
##2.0#	# CONFIG_E2100 is not set
##2.0#	# CONFIG_DEPCA is not set
##2.0#	# CONFIG_EWRK3 is not set
##2.0#	CONFIG_EEXPRESS=m
##2.0#	CONFIG_EEXPRESS_PRO=m
##2.0#	# CONFIG_FMV18X is not set
##2.0#	# CONFIG_HPLAN_PLUS is not set
##2.0#	# CONFIG_HPLAN is not set
##2.0#	# CONFIG_HP100 is not set
##2.0#	# CONFIG_ETH16I is not set
##2.0#	CONFIG_NE2000=m
##2.0#	# CONFIG_NI52 is not set
##2.0#	# CONFIG_NI65 is not set
##2.0#	# CONFIG_SEEQ8005 is not set
##2.0#	# CONFIG_SK_G16 is not set
##2.0#	# CONFIG_NET_EISA is not set
##2.0#	# CONFIG_NET_POCKET is not set
##2.0#	# CONFIG_TR is not set
##2.0#	# CONFIG_FDDI is not set
##2.0#	# CONFIG_ARCNET is not set
##2.0#	# CONFIG_SHAPER is not set
##2.0#	# CONFIG_RCPCI is not set
##2.0#	
##2.0#	#
##2.0#	# ISDN subsystem
##2.0#	#
##2.0#	# CONFIG_ISDN is not set
##2.0#	
##2.0#	#
##2.0#	# CD-ROM drivers (not for SCSI or IDE/ATAPI drives)
##2.0#	#
##2.0#	# CONFIG_CD_NO_IDESCSI is not set
##2.0#	
##2.0#	#
##2.0#	# Filesystems
##2.0#	#
##2.0#	# CONFIG_QUOTA is not set
##2.0#	CONFIG_MINIX_FS=y
##2.0#	# CONFIG_EXT_FS is not set
##2.0#	CONFIG_EXT2_FS=m
##2.0#	# CONFIG_XIA_FS is not set
##2.0#	CONFIG_NLS=y
##2.0#	CONFIG_ISO9660_FS=y
##2.0#	CONFIG_FAT_FS=y
##2.0#	CONFIG_MSDOS_FS=y
##2.0#	CONFIG_UMSDOS_FS=y
##2.0#	CONFIG_VFAT_FS=y
##2.0#	
##2.0#	#
##2.0#	# Select available code pages
##2.0#	#
##2.0#	CONFIG_NLS_CODEPAGE_437=y
##2.0#	# CONFIG_NLS_CODEPAGE_737 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_775 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_850 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_852 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_855 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_857 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_860 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_861 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_862 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_863 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_864 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_865 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_866 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_869 is not set
##2.0#	# CONFIG_NLS_CODEPAGE_874 is not set
##2.0#	CONFIG_NLS_ISO8859_1=y
##2.0#	# CONFIG_NLS_ISO8859_2 is not set
##2.0#	# CONFIG_NLS_ISO8859_3 is not set
##2.0#	# CONFIG_NLS_ISO8859_4 is not set
##2.0#	# CONFIG_NLS_ISO8859_5 is not set
##2.0#	# CONFIG_NLS_ISO8859_6 is not set
##2.0#	# CONFIG_NLS_ISO8859_7 is not set
##2.0#	# CONFIG_NLS_ISO8859_8 is not set
##2.0#	# CONFIG_NLS_ISO8859_9 is not set
##2.0#	CONFIG_NLS_ISO8859_14=m
##2.0#	CONFIG_NLS_ISO8859_15=m
##2.0#	# CONFIG_NLS_KOI8_R is not set
##2.0#	CONFIG_PROC_FS=y
##2.0#	CONFIG_NFS_FS=m
##2.0#	CONFIG_SMB_FS=m
##2.0#	CONFIG_SMB_WIN95=y
##2.0#	CONFIG_HPFS_FS=m
##2.0#	CONFIG_SYSV_FS=m
##2.0#	CONFIG_AUTOFS_FS=y
##2.0#	CONFIG_AFFS_FS=m
##2.0#	CONFIG_AMIGA_PARTITION=y
##2.0#	CONFIG_UFS_FS=m
##2.0#	CONFIG_BSD_DISKLABEL=y
##2.0#	CONFIG_SMD_DISKLABEL=y
##2.0#	
##2.0#	#
##2.0#	# Character devices
##2.0#	#
##2.0#	CONFIG_SERIAL=m
##2.0#	# CONFIG_SERIAL_PCI is not set
##2.0#	# CONFIG_DIGI is not set
##2.0#	# CONFIG_CYCLADES is not set
##2.0#	# CONFIG_ISI is not set
##2.0#	# CONFIG_STALDRV is not set
##2.0#	# CONFIG_RISCOM8 is not set
##2.0#	CONFIG_PRINTER=m
##2.0#	# CONFIG_SPECIALIX is not set
##2.0#	CONFIG_MOUSE=y
##2.0#	CONFIG_ATIXL_BUSMOUSE=m
##2.0#	CONFIG_BUSMOUSE=m
##2.0#	CONFIG_MS_BUSMOUSE=m
##2.0#	CONFIG_PSMOUSE=m
##2.0#	CONFIG_82C710_MOUSE=y
##2.0#	# CONFIG_UMISC is not set
##2.0#	# CONFIG_QIC02_TAPE is not set
##2.0#	CONFIG_FTAPE=m
##2.0#	# CONFIG_WATCHDOG is not set
##2.0#	# CONFIG_RTC is not set
##2.0#	
##2.0#	#
##2.0#	# Sound
##2.0#	#
##2.0#	# CONFIG_SOUND is not set
##2.0#	
##2.0#	#
##2.0#	# Kernel hacking
##2.0#	#
##2.0#	# CONFIG_PROFILE is not set
##2.0#	# CONFIG_SADISTIC_KMALLOC is not set
##2.0#	# CONFIG_SKB_CHECK is not set
