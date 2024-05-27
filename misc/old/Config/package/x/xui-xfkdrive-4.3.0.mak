# xfkdrive v4.3.0		[ since v4.3.0, c.2010-05-07 ]
# last mod WmT, 2010-05-07	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-xfkdrive' -- cross-userland xfkdrive"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_XFKDRIVE_SRC=${PKG_SRC}
CUI_XFKDRIVE_TEMP=cui-xfkdrive-${PKG_VER}

FUDGE_XFKDRIVE_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_XFKDRIVE_EXTRACTED=${EXTTEMP}/${CUI_XFKDRIVE_TEMP}/Makefile

.PHONY: cui-xfkdrive-extracted
cui-xfkdrive-extracted: ${CUI_XFKDRIVE_EXTRACTED}

${CUI_XFKDRIVE_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} xfkdrive-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_XFKDRIVE_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_XFKDRIVE_TEMP}
	mv ${EXTTEMP}/xfkdrive-${PKG_VER} ${EXTTEMP}/${CUI_XFKDRIVE_TEMP}


### ,-----
### |	package configure
### +-----
#
#CUI_XFKDRIVE_CONFIGURED=${EXTTEMP}/${CUI_XFKDRIVE_TEMP}/.config.old
#
#.PHONY: cui-xfkdrive-configured
#cui-xfkdrive-configured: cui-xfkdrive-extracted ${CUI_XFKDRIVXFKDRIVEGURED}
#
### NB. new configuration options in v1.16.x 
#
#${CUI_XFKDRIVE_CONFIGURED}:
#	echo "*** $@ (CONFIGURED) ***"
#	( cd ${EXTTEMP}/${CUI_XFKDRIVE_TEMP} || exit 1 ;\
#		(	case ${PKG_VER} in \
#			1.16.[01]) \
#				echo 'CONFIG_PREFIX="'${FUDGE_XFKDRIVE_INSTROOT}'"' ;\
#				echo 'CONFIG_CROSS_COMPILER_PREFIX="'${CTI_ROOT}'/usr/bin/'${TARGET_SPEC}'-"' ;\
#				\
#				echo 'CONFIG_FEATURE_EDITING=y' ;\
#				echo 'CONFIG_FEATURE_TAB_COMPLETION=y' \
#			;; \
#			*) \
#				echo "xfkdrive: CONFIGURE: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
#				exit 1 \
#			;; \
#			esac ;\
#			echo '# CONFIG_STATIC is not set' ;\
#			echo 'CONFIG_FEATURE_SH_IS_ASH=y' ;\
#			echo 'CONFIG_ASH=y' ;\
#			echo '# CONFIG_FEATURE_SH_IS_HUSH is not set' ;\
#			echo '# CONFIG_HUSH is not set' ;\
#			echo '# CONFIG_LASH is not set' ;\
#			echo '# CONFIG_MSH is not set' ;\
#			\
#			echo 'CONFIG_BASENAME=y' ;\
#			echo 'CONFIG_CAT=y' ;\
#			echo 'CONFIG_CHGRP=y' ;\
#			echo 'CONFIG_CHMOD=y' ;\
#			echo 'CONFIG_CHOWN=y' ;\
#			echo 'CONFIG_CHROOT=y' ;\
#			echo 'CONFIG_CP=y' ;\
#			echo 'CONFIG_DATE=y' ;\
#			echo 'CONFIG_DD=y' ;\
#			echo 'CONFIG_DF=y' ;\
#			echo 'CONFIG_DIRNAME=y' ;\
#			echo 'CONFIG_DU=y' ;\
#			echo 'CONFIG_ECHO=y' ;\
#			echo 'CONFIG_ENV=y' ;\
#			echo 'CONFIG_EXPR=y' ;\
#			echo 'CONFIG_FALSE=y' ;\
#			echo 'CONFIG_TRUE=y' ;\
#			echo 'CONFIG_FDFORMAT=y' ;\
#			[ "${PKG_VER}" = '1.6.1' ] || echo 'CONFIG_FDISK=y' ;\
#			[ "${PKG_VER}" = '1.16.0' ] && echo '# CONFIG_FDISK_SUPPORT_LARGE_DISKS is not set' ;\
#			echo 'CONFIG_FEATURE_FDISK_WRITABLE=y' ;\
#			echo 'CONFIG_FEATURE_FDISK_ADVANCED=y' ;\
#			echo 'CONFIG_GREP=y' ;\
#			echo '# CONFIG_GZIP is not set' ;\
#			echo 'CONFIG_HEAD=y' ;\
#			echo 'CONFIG_TAIL=y' ;\
#			echo 'CONFIG_HALT=y' ;\
#			echo 'CONFIG_HOSTNAME=y' ;\
#			echo 'CONFIG_INIT=y' ;\
#			echo 'CONFIG_FEATURE_USE_INITTAB=y' ;\
#			echo 'CONFIG_LN=y' ;\
#			echo 'CONFIG_LS=y' ;\
#			echo 'CONFIG_MKDIR=y' ;\
#			echo 'CONFIG_MKFS_MINIX=y' ;\
#			echo 'CONFIG_FSCK_MINIX=y' ;\
#			echo 'CONFIG_MKNOD=y' ;\
#			echo 'CONFIG_MKSWAP=y' ;\
#			echo 'CONFIG_SWAPONOFF=y' ;\
#			echo 'CONFIG_MKTEMP=y' ;\
#			echo 'CONFIG_MORE=y' ;\
#			echo 'CONFIG_MOUNT=y' ;\
#			echo 'CONFIG_UMOUNT=y' ;\
#			echo 'CONFIG_FEATURE_MOUNT_LOOP=y' ;\
#			echo 'CONFIG_LOSETUP=y' ;\
#			echo 'CONFIG_MV=y' ;\
#			echo 'CONFIG_PS=y' ;\
#			echo 'CONFIG_PWD=y' ;\
#			echo 'CONFIG_RM=y' ;\
#			echo 'CONFIG_RMDIR=y' ;\
#			echo '# CONFIG_SED is not set' ;\
#			echo 'CONFIG_SLEEP=y' ;\
#			echo 'CONFIG_SORT=y' ;\
#			echo 'CONFIG_STTY=y' ;\
#			echo 'CONFIG_TTY=y' ;\
#			echo 'CONFIG_SYNC=y' ;\
#			echo '# CONFIG_TAR is not set' ;\
#			echo 'CONFIG_TEE=y' ;\
#			echo 'CONFIG_TEST=y' ;\
#			echo 'CONFIG_TOP=y' ;\
#			echo 'CONFIG_TOUCH=y' ;\
#			echo 'CONFIG_TR=y' ;\
#			echo 'CONFIG_UNAME=y' ;\
#			echo 'CONFIG_UNIQ=y' ;\
#			echo 'CONFIG_VI=y' ;\
#			echo 'CONFIG_WHOAMI=y' ;\
#			echo 'CONFIG_YES=y' ;\
#			echo '# CONFIG_MESG is not set' ;\
#			echo '# CONFIG_START_STOP_DAEMON is not set' ;\
#			echo 'CONFIG_INSTALL_APPLET_SYMLINKS=y' \
#		) > .config || exit 1 ;\
#		yes '' | ( make \
#			  HOSTCC=${NATIVE_SPEC}-gcc \
#			  oldconfig ) || exit 1 ;\
#		case ${PKG_VER} in \
#		1.16.[01]) \
#			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
#			cat Makefile.OLD \
#				| sed	' /^ARCH/	s%=.*%= '${TARGET_CPU}'%' \
#				> Makefile || exit 1 ;\
#	                [ -r util-linux/fdisk.c.OLD ] || mv util-linux/fdisk.c util-linux/fdisk.c.OLD || exit 1 ;\
#			cat util-linux/fdisk.c.OLD \
#				| sed 's/lseek64/lseek/ ; s/off64_t/off_t/g' \
#				> util-linux/fdisk.c || exit 1 \
#		;; \
#		*) \
#			echo "xfkdrive: CONFIGURE Makefile: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
#			exit 1 \
#		;; \
#		esac \
#	)	|| exit 1
#
#
### ,-----
### |	package build
### +-----
#
#CUI_XFKDRIVE_BUILT=${EXTTEMP}/${CUI_XFKDRIVE_TEMP}/xfkdrive
#
#.PHONY: cui-xfkdrive-built
#cui-xfkdrive-built: cui-xfkdrive-configured ${CUI_XFKDRIVE_BUILT}
#
#${CUI_XFKDRIVE_BUILT}:
#	echo "*** $@ (BUILT) ***"
#	( cd ${EXTTEMP}/${CUI_XFKDRIVE_TEMP} || exit 1 ;\
#		make KBUILD_VERBOSE=1 || exit 1 \
#	) || exit 1
#
#
### ,-----
### |	package install
### +-----
#
#
#CUI_XFKDRIVE_INSTALLED=${FUDGE_XFKDRIVE_INSTROOT}/bin/xfkdrive
#
#.PHONY: cui-xfkdrive-installed
#cui-xfkdrive-installed: cui-xfkdrive-built ${CUI_XFKDRIVE_INSTALLED}
#
#${CUI_XFKDRIVE_INSTALLED}:
#	mkdir -p ${FUDGE_XFKDRIVE_INSTROOT}
#	( cd ${EXTTEMP}/${CUI_XFKDRIVE_TEMP} || exit 1 ;\
#		make install || exit 1 \
#	) || exit 1

.PHONY: all-CUI
all-CUI: cui-xfkdrive-extracted
#all-CUI: cui-xfkdrive-configured
#all-CUI: cui-xfkdrive-built
#all-CUI: cui-xfkdrive-installed
