# busybox v1.16.1		[ since v0.60.5, c.2006-06-17 ]
# last mod WmT, 2010-04-28	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-busybox' -- cross-userland busybox"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_BUSYBOX_SRC=${PKG_SRC}
CUI_BUSYBOX_TEMP=cui-busybox-${PKG_VER}

FUDGE_BUSYBOX_INSTROOT=${EXTTEMP}/insttemp

LEGUL_BUSYBOX_TARGET_SPEC=$(shell if [ -r ${CTI_ROOT}/usr/${TARGET_SPEC} ] ; then echo ${TARGET_SPEC} ; else echo ${TARGET_SPEC} | sed 's/uclibc$$/gnu/' ; fi)


## ,-----
## |	package extract
## +-----

CUI_BUSYBOX_EXTRACTED=${EXTTEMP}/${CUI_BUSYBOX_TEMP}/Makefile

.PHONY: cui-busybox-extracted
cui-busybox-extracted: ${CUI_BUSYBOX_EXTRACTED}

${CUI_BUSYBOX_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} busybox-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_BUSYBOX_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_BUSYBOX_TEMP}
	mv ${EXTTEMP}/busybox-${PKG_VER} ${EXTTEMP}/${CUI_BUSYBOX_TEMP}


## ,-----
## |	package configure
## +-----

CUI_BUSYBOX_CONFIGURED=${EXTTEMP}/${CUI_BUSYBOX_TEMP}/.config.old

.PHONY: cui-busybox-configured
cui-busybox-configured: cui-busybox-extracted ${CUI_BUSYBOX_CONFIGURED}

## NB. new configuration options in v1.16.x 

${CUI_BUSYBOX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_BUSYBOX_TEMP} || exit 1 ;\
		(	case ${PKG_VER} in \
			1.16.[01]) \
				echo 'CONFIG_PREFIX="'${FUDGE_BUSYBOX_INSTROOT}'"' ;\
				echo 'CONFIG_CROSS_COMPILER_PREFIX="'${CTI_ROOT}'/usr/bin/'${LEGUL_BUSYBOX_TARGET_SPEC}'-"' ;\
				\
				echo 'CONFIG_FEATURE_EDITING=y' ;\
				echo 'CONFIG_FEATURE_TAB_COMPLETION=y' \
			;; \
			*) \
				echo "busybox: CONFIGURE: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
				exit 1 \
			;; \
			esac ;\
			echo '# CONFIG_STATIC is not set' ;\
			echo 'CONFIG_FEATURE_SH_IS_ASH=y' ;\
			echo 'CONFIG_ASH=y' ;\
			echo '# CONFIG_FEATURE_SH_IS_HUSH is not set' ;\
			echo '# CONFIG_HUSH is not set' ;\
			echo '# CONFIG_LASH is not set' ;\
			echo '# CONFIG_MSH is not set' ;\
			\
			echo 'CONFIG_BASENAME=y' ;\
			echo 'CONFIG_CAT=y' ;\
			echo 'CONFIG_CHGRP=y' ;\
			echo 'CONFIG_CHMOD=y' ;\
			echo 'CONFIG_CHOWN=y' ;\
			echo 'CONFIG_CHROOT=y' ;\
			echo 'CONFIG_CP=y' ;\
			echo 'CONFIG_DATE=y' ;\
			echo 'CONFIG_DD=y' ;\
			echo 'CONFIG_DF=y' ;\
			echo 'CONFIG_DIRNAME=y' ;\
			echo 'CONFIG_DU=y' ;\
			echo 'CONFIG_ECHO=y' ;\
			echo 'CONFIG_ENV=y' ;\
			echo 'CONFIG_EXPR=y' ;\
			echo 'CONFIG_FALSE=y' ;\
			echo 'CONFIG_TRUE=y' ;\
			echo 'CONFIG_FDFORMAT=y' ;\
			[ "${PKG_VER}" = '1.6.1' ] || echo 'CONFIG_FDISK=y' ;\
			[ "${PKG_VER}" = '1.16.0' ] && echo '# CONFIG_FDISK_SUPPORT_LARGE_DISKS is not set' ;\
			echo 'CONFIG_FEATURE_FDISK_WRITABLE=y' ;\
			echo 'CONFIG_FEATURE_FDISK_ADVANCED=y' ;\
			echo 'CONFIG_GREP=y' ;\
			echo '# CONFIG_GZIP is not set' ;\
			echo 'CONFIG_HEAD=y' ;\
			echo 'CONFIG_TAIL=y' ;\
			echo 'CONFIG_HALT=y' ;\
			echo 'CONFIG_HOSTNAME=y' ;\
			echo 'CONFIG_INIT=y' ;\
			echo 'CONFIG_FEATURE_USE_INITTAB=y' ;\
			echo 'CONFIG_LN=y' ;\
			echo 'CONFIG_LS=y' ;\
			echo 'CONFIG_MKDIR=y' ;\
			echo 'CONFIG_MKFS_MINIX=y' ;\
			echo 'CONFIG_FSCK_MINIX=y' ;\
			echo 'CONFIG_MKNOD=y' ;\
			echo 'CONFIG_MKSWAP=y' ;\
			echo 'CONFIG_SWAPONOFF=y' ;\
			echo 'CONFIG_MKTEMP=y' ;\
			echo 'CONFIG_MORE=y' ;\
			echo 'CONFIG_MOUNT=y' ;\
			echo 'CONFIG_UMOUNT=y' ;\
			echo 'CONFIG_FEATURE_MOUNT_LOOP=y' ;\
			echo 'CONFIG_LOSETUP=y' ;\
			echo 'CONFIG_MV=y' ;\
			echo 'CONFIG_PS=y' ;\
			echo 'CONFIG_PWD=y' ;\
			echo 'CONFIG_RM=y' ;\
			echo 'CONFIG_RMDIR=y' ;\
			echo '# CONFIG_SED is not set' ;\
			echo 'CONFIG_SLEEP=y' ;\
			echo 'CONFIG_SORT=y' ;\
			echo 'CONFIG_STTY=y' ;\
			echo 'CONFIG_TTY=y' ;\
			echo 'CONFIG_SYNC=y' ;\
			echo '# CONFIG_TAR is not set' ;\
			echo 'CONFIG_TEE=y' ;\
			echo 'CONFIG_TEST=y' ;\
			echo 'CONFIG_TOP=y' ;\
			echo 'CONFIG_TOUCH=y' ;\
			echo 'CONFIG_TR=y' ;\
			echo 'CONFIG_UNAME=y' ;\
			echo 'CONFIG_UNIQ=y' ;\
			echo 'CONFIG_VI=y' ;\
			echo 'CONFIG_WHOAMI=y' ;\
			echo 'CONFIG_YES=y' ;\
			echo '# CONFIG_MESG is not set' ;\
			echo '# CONFIG_START_STOP_DAEMON is not set' ;\
			echo 'CONFIG_INSTALL_APPLET_SYMLINKS=y' \
		) > .config || exit 1 ;\
		yes '' | ( make \
			  HOSTCC=${NATIVE_SPEC}-gcc \
			  oldconfig ) || exit 1 ;\
		case ${PKG_VER} in \
		1.16.[01]) \
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
			cat Makefile.OLD \
				| sed	' /^ARCH/	s%=.*%= '${TARGET_CPU}'%' \
				> Makefile || exit 1 ;\
	                [ -r util-linux/fdisk.c.OLD ] || mv util-linux/fdisk.c util-linux/fdisk.c.OLD || exit 1 ;\
			cat util-linux/fdisk.c.OLD \
				| sed 's/lseek64/lseek/ ; s/off64_t/off_t/g' \
				> util-linux/fdisk.c || exit 1 \
		;; \
		*) \
			echo "busybox: CONFIGURE Makefile: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_BUSYBOX_BUILT=${EXTTEMP}/${CUI_BUSYBOX_TEMP}/busybox

.PHONY: cui-busybox-built
cui-busybox-built: cui-busybox-configured ${CUI_BUSYBOX_BUILT}

${CUI_BUSYBOX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_BUSYBOX_TEMP} || exit 1 ;\
		make KBUILD_VERBOSE=1 || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_BUSYBOX_INSTALLED=${FUDGE_BUSYBOX_INSTROOT}/bin/busybox

.PHONY: cui-busybox-installed
cui-busybox-installed: cui-busybox-built ${CUI_BUSYBOX_INSTALLED}

${CUI_BUSYBOX_INSTALLED}:
	mkdir -p ${FUDGE_BUSYBOX_INSTROOT}
	( cd ${EXTTEMP}/${CUI_BUSYBOX_TEMP} || exit 1 ;\
		make install || exit 1 \
	) || exit 1

.PHONY: all-CUI
all-CUI: cui-busybox-installed
