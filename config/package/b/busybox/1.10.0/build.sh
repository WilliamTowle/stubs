#!/bin/sh
# 2008-04-05

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	case ${PKGVER} in
	0.60.5)
		[ -r Config.h.OLD ] || mv Config.h Config.h.OLD || exit 1
		cat Config.h.OLD \
			| sed 's%#define BB_CHVT%//#define BB_CHVT	/* WmT, 0.60.5-5 */%' \
			| sed 's%//#define BB_EXPR$%#define BB_EXPR	/* WmT */%' \
			| sed 's%//#define BB_FDFLUSH$%#define BB_FDFLUSH	/* WmT */%' \
			| sed 's%#define BB_GUNZIP$%//#define BB_GUNZIP	/* WmT */%' \
			| sed 's%#define BB_GZIP$%//#define BB_GZIP	/* WmT */%' \
			| sed 's%//#define BB_HOSTNAME$%#define BB_HOSTNAME	/* WmT */%' \
			| sed 's%#define BB_ID$%//#define BB_ID	/* WmT */%' \
			| sed 's%//#define BB_IFCONFIG$%#define BB_IFCONFIG	/* WmT */%' \
			| sed 's%//#define BB_INSMOD$%#define BB_INSMOD	/* WmT, for 0.2.5 */%' \
			| sed 's%#define BB_KLOGD$%//#define BB_KLOGD	/* WT */%' \
			| sed 's%#define BB_LOGGER$%//#define BB_LOGGER	/* WmT */%' \
			| sed 's%//#define BB_MKTEMP$%#define BB_MKTEMP	/* WmT, for e3 */%' \
			| sed 's%#define BB_MODPROBE$%//#define BB_MODPROBE	/* WmT */%' \
			| sed 's%//#define BB_PING$%#define BB_PING	/* WmT */%' \
			| sed 's%//#define BB_RMMOD$%#define BB_RMMOD	/* WmT, for 0.2.5 */%' \
			| sed 's%//#define BB_ROUTE$%#define BB_ROUTE	/* WmT, for 0.2.5 */%' \
			| sed 's%#define BB_SED$%//#define BB_SED	/* WmT - we use GNU */%' \
			| sed 's%//#define BB_STTY$%#define BB_STTY	/* WmT */%' \
			| sed 's%#define BB_SYSLOGD$%//#define BB_SYSLOGD	/* WmT */%' \
			| sed 's%#define BB_TAR$%//#define BB_TAR	/* WmT */%' \
			| sed 's%//#define BB_TEE$%#define BB_TEE	/* WmT */%' \
			| sed 's%//#define BB_TEST$%#define BB_TEST	/* WmT */%' \
			| sed 's%//#define BB_TR$%#define BB_TR	/* WmT (not sure why) */%' \
			| sed 's%//#define BB_TRACEROUTE$%#define BB_TRACEROUTE	/* WmT, for 0.2.5 */%' \
			| sed 's%#define BB_TTY$%//#define BB_TTY	/* WmT */%' \
			| sed 's%//#define BB_VI$%#define BB_VI	/* WmT, for 0.3.1 */%' \
			| sed 's%#define BB_WC$%//#define BB_WC	/* WmT */%' \
			| sed 's%#define BB_XARGS$%//#define BB_XARGS	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_USE_TERMIOS$%#define BB_FEATURE_USE_TERMIOS	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_MTAB_SUPPORT$%#define BB_FEATURE_MTAB_SUPPORT	/* WmT */%' \
			| sed 's%#define BB_FEATURE_NEW_MODULE_INTERFACE$%//#define BB_FEATURE_NEW_MODULE_INTERFACE	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_OLD_MODULE_INTERFACE$%#define BB_FEATURE_OLD_MODULE_INTERFACE	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_INSMOD_VERSION_CHECKING$%#define BB_FEATURE_INSMOD_VERSION_CHECKING	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_IFCONFIG_STATUS$%#define BB_FEATURE_IFCONFIG_STATUS	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_GREP_EGREP_ALIAS$%#define BB_FEATURE_GREP_EGREP_ALIAS	/* WmT */%' \
			> Config.h || exit 1

		[ -r Makefile.OLD ] \
			|| cp Makefile Makefile.OLD || exit 1
		case ${PHASE} in
		dc)
			cat Makefile.OLD \
				| sed 's/-march=i386//' \
				| sed '/^#CROSS_CFLAGS/ s/^#//' \
				> Makefile || exit 1
		;;
		th)
			cat Makefile.OLD \
				| sed 's/-march=i386//' \
				| sed '/^#CROSS_CFLAGS/ s/^#//' \
				> Makefile || exit 1
		;;
		esac

		[ -r busybox.mkll.OLD ] \
			|| mv busybox.mkll busybox.mkll.OLD || exit 1
		cat busybox.mkll.OLD \
			| sed 's%^gcc%'${FR_CROSS_CC}'%' \
			> busybox.mkll || exit 1
	;;
	1.*)
		(	case ${PKGVER} in
			1.2.2.*)
				echo 'USING_CROSS_COMPILER=y'
				echo 'PREFIX="'${INSTTEMP}'"'
				echo 'CROSS_COMPILER_PREFIX="'${FR_TC_ROOT}'/usr/bin/'${FR_TARGET_DEFN}'-"'
				echo '# CONFIG_FEATURE_IPC_SYSLOG_BUFFER_SIZE is not set'
				echo 'CONFIG_FEATURE_COMMAND_EDITING=y'
				echo 'CONFIG_FEATURE_COMMAND_TAB_COMPLETION=y'
			;;
			1.5.[01]|1.6.[01]|1.7.[12]|1.8.[012]|1.9.[02]|1.10.0)
				echo 'CONFIG_PREFIX="'${INSTTEMP}'"'
				echo 'CONFIG_FEATURE_EDITING=y'
				echo 'CONFIG_FEATURE_EDITING_FANCY_KEYS=y'
				echo 'CONFIG_FEATURE_TAB_COMPLETION=y'
			;;
			*)
				echo "Configure PREFIX: Unexpected PKGVER ${PKGVER}" 1>&2
				exit 1
			;;
			esac
			echo '# CONFIG_STATIC is not set'
			[ ${PKGVER} = '1.3.0' ] && echo 'CONFIG_FEATURE_SHADOWPASSWDS=y'
			[ ${PKGVER} = '1.3.1' ] && echo 'CONFIG_FEATURE_SHADOWPASSWDS=y'
			[ ${PKGVER} = '1.3.0' ] && echo 'CONFIG_USE_BB_SHADOW=y'
			[ ${PKGVER} = '1.3.1' ] && echo 'CONFIG_USE_BB_SHADOW=y'
			[ ${PKGVER} = '1.3.0' ] && echo 'CONFIG_USE_BB_PWD_GRP=y'
			[ ${PKGVER} = '1.3.1' ] && echo 'CONFIG_USE_BB_PWD_GRP=y'
			echo 'CONFIG_FEATURE_SH_IS_ASH=y'
			echo 'CONFIG_ASH=y'
			echo '# CONFIG_FEATURE_SH_IS_HUSH is not set'
			echo '# CONFIG_HUSH is not set'
			echo '# CONFIG_FEATURE_SH_IS_LASH is not set'
			echo '# CONFIG_LASH is not set'
			echo '# CONFIG_FEATURE_SH_IS_MSH is not set'
			echo '# CONFIG_MSH is not set'
			echo 'CONFIG_BASENAME=y'
			echo 'CONFIG_DATE=y'
			echo 'CONFIG_DIRNAME=y'
			echo 'CONFIG_CAT=y'
			echo 'CONFIG_CHGRP=y'
			echo 'CONFIG_CHMOD=y'
			echo 'CONFIG_CHOWN=y'
			echo 'CONFIG_CHROOT=y'
			echo 'CONFIG_CP=y'
			echo 'CONFIG_ECHO=y'
			echo 'CONFIG_EXPR=y'
			echo 'CONFIG_FALSE=y'
			echo 'CONFIG_TRUE=y'
			echo 'CONFIG_FDFORMAT=y'
			echo 'CONFIG_FDISK=y'
			case ${PKGVER} in
			1.1.0)
				echo '# FDISK_SUPPORT_LARGE_DISKS is not set'
			;;
			1.7.[12]|1.8.[012]|1.9.[02]|1.10.0) ;;
			*)
				echo '# CONFIG_FDISK_SUPPORT_LARGE_DISKS is not set'
			;;
			esac
			echo 'CONFIG_FEATURE_FDISK_WRITABLE=y'
			echo 'CONFIG_FEATURE_FDISK_ADVANCED=y'
			echo 'CONFIG_GREP=y'
			echo '# CONFIG_GZIP is not set'
			echo 'CONFIG_HALT=y'
			echo 'CONFIG_REBOOT=y'
			echo '# CONFIG_POWEROFF is not set'
			echo 'CONFIG_HEAD=y'
			echo 'CONFIG_TAIL=y'
			echo 'CONFIG_HOSTNAME=y'
			echo 'CONFIG_IFCONFIG=y'
			echo 'CONFIG_FEATURE_IFCONFIG_STATUS=y'
			echo 'CONFIG_ROUTE=y'
			echo 'CONFIG_LN=y'
			echo 'CONFIG_LOSETUP=y'
			echo 'CONFIG_LS=y'
			echo 'CONFIG_MKDIR=y'
			echo 'CONFIG_MKFS_MINIX=y'
			echo 'CONFIG_FSCK_MINIX=y'
			echo 'CONFIG_MKNOD=y'
			echo 'CONFIG_MKSWAP=y'
			echo 'CONFIG_SWAPONOFF=y'
			echo 'CONFIG_MKTEMP=y'
			echo 'CONFIG_MORE=y'
			echo 'CONFIG_MOUNT=y'
			echo 'CONFIG_FEATURE_MOUNT_LOOP=y'
			echo 'CONFIG_MV=y'
			echo 'CONFIG_PS=y'
			echo 'CONFIG_PWD=y'
			echo 'CONFIG_RM=y'
			echo 'CONFIG_RMDIR=y'
			echo '# CONFIG_SED is not set'
			echo 'CONFIG_SORT=y'
			[ "${PKGVER}" = '1.1.0' ] && echo '# CONFIG_FEATURE_SORT_BIG is not set'
			echo 'CONFIG_SLEEP=y'
			echo 'CONFIG_STTY=y'
			echo 'CONFIG_TTY=y'
			echo 'CONFIG_SYNC=y'
			echo '# CONFIG_TAR is not set'
			echo 'CONFIG_FEATURE_TAR_GZIP=y'
			echo 'CONFIG_TEE=y'
			echo 'CONFIG_TEST=y'
			echo 'CONFIG_TOP=y'
			echo 'CONFIG_TOUCH=y'
			echo 'CONFIG_TR=y'
			echo 'CONFIG_UNAME=y'
			echo 'CONFIG_UNIQ=y'
			echo 'CONFIG_VI=y'
			echo 'CONFIG_WHOAMI=y'
			echo 'CONFIG_YES=y'
			echo '# CONFIG_MESG is not set'
			echo '# CONFIG_START_STOP_DAEMON is not set'
			echo 'CONFIG_INSTALL_APPLET_SYMLINKS=y'
		) > .config || exit 1
		yes '' | ( make HOSTCC=${FR_HOST_CC} \
			  oldconfig ) || exit 1
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD
		cat Makefile.OLD \
			| sed	' /^ARCH/	s%=.*%= '${TARGET_CPU}'%' \
			| sed	' /^CROSS_COMPILE/	s%=.*%= '`echo ${FR_CROSS_CC} | sed 's/gcc$//'`'%' \
			> Makefile || exit 1
		case ${PKGVER} in
		1.4.1)
			[ -r scripts/trylink.OLD ] || mv scripts/trylink scripts/trylink.OLD || exit 1
			cat scripts/trylink.OLD \
				| sed 's/function try/try()/' \
				> scripts/trylink || exit 1
			chmod a+x scripts/trylink || exit 1
		;;
		1.7.[12]|1.8.[012]|1.9.[02]|1.10.0)
			[ -r util-linux/fdisk.c.OLD ] || mv util-linux/fdisk.c util-linux/fdisk.c.OLD || exit 1
			cat util-linux/fdisk.c.OLD \
				| sed 's/lseek64/lseek/ ; s/off64_t/off_t/g' \
				> util-linux/fdisk.c || exit 1
		;;
		esac
	;;
	*)
 		echo "$0: do_configure(): Unexpected PKGVER ${PKGVER}" 1>&2
 		exit 1
	;;
	esac
}

do_post_inst()
{
	case $0 in
	/*)	;;	# OK
	*)	echo "$0 not fully pathed :(" 1>&2
		exit 1
	;;
	esac

# true/false: executable shrinks by just 116 bytes without - no saving
#	( cd ${INSTTEMP}/bin && (
#		[ -L false ] && exit 1
#		[ -L true ] && exit 1
#		cat $0 | grep '^#tf#' | sed 's/.....//' > false
#		ln -sf false true
#		chmod a+x false
#	) || exit 1 ) || exit 1

	mkdir -p ${INSTTEMP}/sbin || exit 1
	( cd ${INSTTEMP}/sbin && (
		[ -L fsck ] && rm fsck
		[ -L mkfs ] && rm mkfs
		cat $0 | grep '^#mkfsck#' | sed 's/.........//' > fsck
		ln -sf fsck mkfs
		[ -L shutdown ] && exit 1
		cat $0 | grep '^#shdn#' | sed 's/.......//' > shutdown
		chmod a+x mkfs shutdown
	) || exit 1 ) || exit 1

	( cd ${INSTTEMP}/usr/bin && (
		[ ! -L tail ] || rm tail
		cat $0 | grep '^#tail#' | sed 's/.......//' > tail
		chmod a+x tail
	) || exit 1 ) || exit 1

# yes: executable shrinks by just 288 bytes without - no saving
#	( cd ${INSTTEMP}/usr/bin && (
#		[ -L yes ] && exit 1
#		cat $0 | grep '^#yes#' | sed 's/......//' > yes
#		chmod a+x yes
#	) || exit 1 ) || exit 1
}

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
		GCCINCDIR=`${FR_CROSS_CC} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/'`
	fi

	PHASE=dc do_configure || exit 1

# BUILD/INSTALL
	case ${PKGVER} in
	0.60.5)
		# (30/01/2005) needs 'awk' and 'install' PATHed
		PATH=${FR_TH_ROOT}/bin:${FR_TH_ROOT}/usr/bin:${FR_TC_ROOT}/bin:${PATH} \
			make CROSS=`echo ${FR_CROSS_CC} | sed 's/gcc$//'` \
			  PREFIX=${INSTTEMP} \
			  LIBCDIR=${FR_LIBCDIR} \
			  GCCINCDIR=${GCCINCDIR} \
			  install || exit 1
	;;
	1.1.0|1.2.2.1|1.4.1)
		make || exit 1
	;;
	1.5.[01]|1.6.[01]|1.7.[12]|1.8.[012]|1.9.[02]|1.10.0)
		make KBUILD_VERBOSE=1 || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# INSTALL...
	case ${PKGVER} in
	1.1.0|1.2.2.1|1.4.1|1.6.[01]|1.7.[12]|1.8.[012]|1.9.[02]|1.10.0)
		make install || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
	do_post_inst ${INSTTEMP} || exit 1
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

#tail#	#!/bin/sh
#tail#	# franki/earlgrey /usr/bin/tail, WmT 04/05/2003
#tail#
#tail#	START=''
#tail#
#tail#	case $1 in
#tail#	+[0-9])
#tail#		START=`echo $1 | sed 's/^+//'` || exit 1
#tail#		shift
#tail#	;;
#tail#	+[0-9]*)
#tail#		echo "$0: $1: >=10 -> too large"
#tail#	esac
#tail#
#tail#	if [ "${START}" ] ; then
#tail#		cat $* | while read LINE ; do
#tail#			START=`echo ${START} | tr '9876543210' '8765432100'`
#tail#			[ "${START}" = '0' ] && echo ${LINE}
#tail#		done
#tail#	else
#tail#		/bin/busybox tail $*
#tail#	fi

#mkfsck#	#!/bin/sh
#mkfsck#	# franki/earlgrey /sbin/{mkfs, fsck}, WmT 20/04/2003
#mkfsck#
#mkfsck#	ARG1=$1
#mkfsck#	if [ -z "${ARG1}" ] ; then
#mkfsck#		# Would absent '-t' be a problem (...which fs to assume?)
#mkfsck#		echo "$0: Need '-t' argument"
#mkfsck#		exit 1
#mkfsck#	elif [ "${ARG1}" != '-t' ] ; then
#mkfsck#		echo "$0: First argument wasn't '-t'"
#mkfsck#		exit 1
#mkfsck#	else
#mkfsck#		shift
#mkfsck#	fi
#mkfsck#
#mkfsck#	FSTYPE=$1
#mkfsck#	if [ -z "${FSTYPE}" ] ; then
#mkfsck#		echo "$0: Expected FSTYPE for '-t'"
#mkfsck#		exit 1
#mkfsck#	else
#mkfsck#		shift
#mkfsck#	fi
#mkfsck#
#mkfsck#	if [ -r /proc/filesystems ] ; then
#mkfsck#		KNOWN=`grep "	${FSTYPE}$" /proc/filesystems`
#mkfsck#		[ "${KNOWN}" ] || echo "$0: Warning: Don't know ${FSTYPE} filesystem"
#mkfsck#	fi
#mkfsck#
#mkfsck#	MKFSCK=$0.${FSTYPE}
#mkfsck#	if [ ! -f ${MKFSCK} ] ; then
#mkfsck#		echo "$0: Confused -- No ${MKFSCK} executable"
#mkfsck#		exit 1
#mkfsck#	fi
#mkfsck#
#mkfsck#	${MKFSCK} $* || exit 1
#mkfsck#	echo "$0: OK"

#shdn#	#!/bin/sh
#shdn#	# franki/earlgrey /sbin/shutdown, WmT 22/03/2003
#shdn#
#shdn#	do_shutdown()
#shdn#	{
#shdn#		echo "[$0]: 'Sync'ing disks..."
#shdn#		sync || exit 1
#shdn#		echo "[$0]: Unmounting filesystems..."
#shdn#
#shdn#		if [ -r /proc/mounts ] ; then
#shdn#			cat /proc/mounts | while read LINE ; do
#shdn#				set -- ${LINE}
#shdn#				DIR=$2
#shdn#				case ${DIR} in
#shdn#				/|/proc*) ;;
#shdn#				*)
#shdn#					${DONT} umount ${DIR}
#shdn#				;;
#shdn#				esac
#shdn#			done
#shdn#		else
#shdn#			mount | sed 's/ on / /' | while read LINE ; do
#shdn#				set -- ${LINE}
#shdn#				DIR=$2
#shdn#				case ${DIR} in
#shdn#				/|/proc*) ;;
#shdn#				*)
#shdn#					${DONT} umount ${DIR}
#shdn#				;;
#shdn#				esac
#shdn#			done
#shdn#		fi
#shdn#
#shdn#		WS=" 	"
#shdn#		ROOTSPEC=`cat /etc/mtab | grep "[${WS}]/[${WS}]"`
#shdn#		ROOT=`echo ${ROOTSPEC} | sed "s/[${WS}].*//"`
#shdn#		if [ "${ROOT}" ] ; then
#shdn#			UMSROOT=`echo ${ROOTSPEC} | grep umsdos`
#shdn#			[ "${UMSROOT}" ] || ${DONT} umount -n -r ${ROOT}
#shdn#		else
#shdn#			${DONT} umount -n -r /
#shdn#		fi
#shdn#
#shdn#		echo "[$0]: Executing $*"
#shdn#		${DONT} $* || exit 1
#shdn#	}
#shdn#
#shdn#	ARG1=$1
#shdn#	if [ -z "${ARG1}" ] ; then
#shdn#		echo "$0: Expected argument '-r' or '-h'"
#shdn#		exit 1
#shdn#	fi
#shdn#	case ${ARG1} in
#shdn#	-h)
#shdn#		do_shutdown /sbin/halt
#shdn#	;;
#shdn#	-H)
#shdn#		DONT=echo do_shutdown /sbin/halt
#shdn#	;;
#shdn#	-r)
#shdn#		do_shutdown /sbin/reboot
#shdn#	;;
#shdn#	-R)
#shdn#		DONT=echo do_shutdown /sbin/reboot
#shdn#	;;
#shdn#	*)
#shdn#		echo "$0: Unexpected argument ${ARG1}"
#shdn#		exit 1
#shdn#	esac

#tf#	#!/bin/sh
#tf#
#tf#	[ `basename $0` = 'true' ]

#yes#	#!/bin/sh
#yes#
#yes#	MSG=y
#yes#	[ $# = 0 ] || MSG=$@
#yes#
#yes#	while [ 1 ] ; do echo ${MSG} ; done
