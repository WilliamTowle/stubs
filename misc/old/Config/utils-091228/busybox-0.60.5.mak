## busybox v0.60.5		[ EARLIEST v0.??.?, c.????-??-?? ]
## last mod WmT, 2009-12-08	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'nti-busybox' -- host-toolchain busybox"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

NTI_BUSYBOX_SRC=${PKG_SRC}
NTI_BUSYBOX_TEMP=nti-busybox-${PKG_VER}

## ,-----
## |	package extract
## +-----

NTI_BUSYBOX_EXTRACTED=${EXTTEMP}/${NTI_BUSYBOX_TEMP}/Makefile

.PHONY: nti-busybox-extracted
nti-busybox-extracted: ${NTI_BUSYBOX_EXTRACTED}

${NTI_BUSYBOX_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} busybox-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_BUSYBOX_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_BUSYBOX_TEMP}
	mv ${EXTTEMP}/busybox-${PKG_VER} ${EXTTEMP}/${NTI_BUSYBOX_TEMP}


## ,-----
## |	package configure
## +-----

NTI_BUSYBOX_CONFIGURED=${EXTTEMP}/${NTI_BUSYBOX_TEMP}/Config.h.OLD

.PHONY: nti-busybox-configured
nti-busybox-configured: nti-busybox-extracted ${NTI_BUSYBOX_CONFIGURED}

${NTI_BUSYBOX_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_BUSYBOX_TEMP} || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^CC/ s%=.*%= '${NATIVE_GCC}'%' \
			| sed '/^AR/ s%=.*%= '`echo ${NATIVE_GCC} | sed 's/g*cc/ar/'`'%' \
			> Makefile || exit 1 ;\
		[ -r busybox.mkll.OLD ] || mv busybox.mkll busybox.mkll.OLD || exit 1 ;\
		cat busybox.mkll.OLD \
			| sed	's%^gcc%'${NATIVE_GCC}'%' \
			> busybox.mkll || exit 1 ;\
		[ -r Config.h.OLD ] || mv Config.h Config.h.OLD || exit 1 ;\
		cat Config.h.OLD \
			| sed '/BusyBox Applications/,/End of Applications/ s%^#define%//#define%' \
			| sed '/define BB_CUT/	s%//%%' \
			| sed '/define BB_READLINK/	s%//%%' \
			| sed '/define BB_WC/	s%//%%' \
			> Config.h \
	)	|| exit 1


## ,-----
## |	package build
## +-----

NTI_BUSYBOX_BUILT=${EXTTEMP}/${NTI_BUSYBOX_TEMP}/src/grep

.PHONY: nti-busybox-built
nti-busybox-built: nti-busybox-configured ${NTI_BUSYBOX_BUILT}

${NTI_BUSYBOX_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_BUSYBOX_TEMP} || exit 1 ;\
		make || exit 1 \
	)


#### ,-----
#### |	package build
#### +-----
##
##NTI_BUSYBOX_BUILT=${EXTTEMP}/${NTI_BUSYBOX_TEMP}/busybox
##
##.PHONY: nti-busybox-built
##nti-busybox-built: nti-busybox-configured ${NTI_BUSYBOX_BUILT}
##
##${NTI_BUSYBOX_BUILT}:
##	echo "*** $@ (BUILT) ***"
##	( cd ${EXTTEMP}/${NTI_BUSYBOX_TEMP} || exit 1 ;\
##		make || exit 1 \
##	)
##
##### ,-----
##### |	Build [htc]
##### +-----
####
####${EXTTEMP}/${BUSYBOX_PATH}-htc/bash: ${EXTTEMP}/${BUSYBOX_PATH}-htc/Makefile
####	( cd ${EXTTEMP}/${BUSYBOX_PATH}-htc || exit 1 ;\
####		make || exit 1 \
####	) || exit 1
##
#### ,-----
#### |	package install
#### +-----
##
##
##
##### ,-----
##### |	Install [htc]
##### +-----
####
####${NTI_ROOT}/bin/bash:
####	${MAKE} ${EXTTEMP}/${BUSYBOX_PATH}-htc/bash
####	( cd ${EXTTEMP}/${BUSYBOX_PATH}-htc || exit 1 ;\
####		make install || exit 1 \
####	) || exit 1
####ifeq (${HAVE_PTRACKING},y)
####	DBROOT=${NTI_ROOT} ${PTRACK_SCRIPT} upgrade ${BUSYBOX_PKG} ${PKG_VER}
####endif
####
##### ,-----
##### |	Entry Points [htc]
##### +-----
###
###.PHONY: nti-bash
###nti-bash: nti-diffutils-installed nti-busybox-installed
###
###NTI_TARGETS+= nti-bash
##
#### busybox 0.60.5		[ since 0.60.5]
#### last mod WmT, 02/04/2007	[ (c) and GPLv2 1999-2007 ]
###
#### ,-----
#### |	Settings
#### +-----
###
###BUSYBOX_PKG:=busybox
###PKG_VER:=0.60.5
####PKG_VER:=1.0.1
####PKG_VER:=1.1.3
####BUSYBOX_VER:=1.2.2.1
###
###BUSYBOX_SRC:=
###BUSYBOX_SRC+=${SOURCEROOT}/b/busybox-${PKG_VER}.tar.bz2
###
###BUSYBOX_PATH:=busybox-${PKG_VER}
###BUSYBOX_INSTTEMP:=${EXTTEMP}/${BUSYBOX_PATH}-insttemp
###BUSYBOX_EGPNAME:=busybox-${PKG_VER}
###
###URLS+=http://www.busybox.net/downloads/legacy/busybox-0.60.5.tar.bz2
####URLS+=http://busybox.net/downloads/busybox-${PKG_VER}.tar.bz2
###
####DEPS:=
##
##
##
#### ,-----
#### |	Configure [xdc]
#### +-----
###
###
###	[ ! -d ${EXTTEMP}/${BUSYBOX_PATH}-xdc ] || rm -rf ${EXTTEMP}/${BUSYBOX_PATH}-xdc
###	mv ${EXTTEMP}/${BUSYBOX_PATH} ${EXTTEMP}/${BUSYBOX_PATH}-xdc
###	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
###		[ -r Config.h.OLD ] || mv Config.h Config.h.OLD || exit 1 ;\
###		cat Config.h.OLD \
###			| sed 's%#define BB_CHVT%//#define BB_CHVT	/* WmT, 0.60.5-5 */%' \
###			| sed 's%//#define BB_EXPR$$%#define BB_EXPR	/* WmT */%' \
###			| sed 's%#define BB_FIND$$%//#define BB_FIND	/* WmT */%' \
###			| sed 's%//#define BB_FDFLUSH$$%#define BB_FDFLUSH	/* WmT */%' \
###			| sed 's%//#define BB_FSCK_MINIX$$%#define BB_FSCK_MINIX	/* WmT */%' \
###			| sed 's%#define BB_GUNZIP$$%//#define BB_GUNZIP	/* WmT */%' \
###			| sed 's%#define BB_GZIP$$%//#define BB_GZIP	/* WmT */%' \
###			| sed 's%//#define BB_HOSTNAME$$%#define BB_HOSTNAME	/* WmT */%' \
###			| sed 's%#define BB_ID$$%//#define BB_ID	/* WmT */%' \
###			| sed 's%//#define BB_IFCONFIG$$%#define BB_IFCONFIG	/* WmT */%' \
###			| sed 's%//#define BB_INSMOD$$%#define BB_INSMOD	/* WmT, for 0.2.5 */%' \
###			| sed 's%#define BB_KLOGD$$%//#define BB_KLOGD	/* WT */%' \
###			| sed 's%#define BB_LOGGER$$%//#define BB_LOGGER	/* WmT */%' \
###			| sed 's%//#define BB_MKTEMP$$%#define BB_MKTEMP	/* WmT, for e3 */%' \
###			| sed 's%//#define BB_MKFS_MINIX$$%#define BB_MKFS_MINIX	/* WmT */%' \
###			| sed 's%#define BB_MODPROBE$$%//#define BB_MODPROBE	/* WmT */%' \
###			| sed 's%//#define BB_PING$$%#define BB_PING	/* WmT */%' \
###			| sed 's%//#define BB_RMMOD$$%#define BB_RMMOD	/* WmT, for 0.2.5 */%' \
###			| sed 's%//#define BB_ROUTE$$%#define BB_ROUTE	/* WmT, for 0.2.5 */%' \
###			| sed 's%#define BB_SED$$%//#define BB_SED	/* WmT - we use GNU */%' \
###			| sed 's%//#define BB_STTY$$%#define BB_STTY	/* WmT */%' \
###			| sed 's%#define BB_SYSLOGD$$%//#define BB_SYSLOGD	/* WmT */%' \
###			| sed 's%#define BB_TAR$$%//#define BB_TAR	/* WmT */%' \
###			| sed 's%//#define BB_TEE$$%#define BB_TEE	/* WmT */%' \
###			| sed 's%//#define BB_TEST$$%#define BB_TEST	/* WmT */%' \
###			| sed 's%//#define BB_TR$$%#define BB_TR	/* WmT (not sure why) */%' \
###			| sed 's%//#define BB_TRACEROUTE$$%#define BB_TRACEROUTE	/* WmT, for 0.2.5 */%' \
###			| sed 's%#define BB_TTY$$%//#define BB_TTY	/* WmT */%' \
###			| sed 's%//#define BB_VI$$%#define BB_VI	/* WmT, for 0.3.1 */%' \
###			| sed 's%#define BB_WC$$%//#define BB_WC	/* WmT */%' \
###			| sed 's%#define BB_XARGS$$%//#define BB_XARGS	/* WmT */%' \
###			| sed 's%//#define BB_FEATURE_USE_TERMIOS$$%#define BB_FEATURE_USE_TERMIOS	/* WmT */%' \
###			| sed 's%//#define BB_FEATURE_MTAB_SUPPORT$$%#define BB_FEATURE_MTAB_SUPPORT	/* WmT */%' \
###			| sed 's%#define BB_FEATURE_NEW_MODULE_INTERFACE$$%//#define BB_FEATURE_NEW_MODULE_INTERFACE	/* WmT */%' \
###			| sed 's%//#define BB_FEATURE_OLD_MODULE_INTERFACE$$%#define BB_FEATURE_OLD_MODULE_INTERFACE	/* WmT */%' \
###			| sed 's%//#define BB_FEATURE_INSMOD_VERSION_CHECKING$$%#define BB_FEATURE_INSMOD_VERSION_CHECKING	/* WmT */%' \
###			| sed 's%//#define BB_FEATURE_IFCONFIG_STATUS$$%#define BB_FEATURE_IFCONFIG_STATUS	/* WmT */%' \
###			| sed 's%//#define BB_FEATURE_GREP_EGREP_ALIAS$$%#define BB_FEATURE_GREP_EGREP_ALIAS	/* WmT */%' \
###		> Config.h || exit 1 ;\
###		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
###		cat Makefile.OLD \
###			| sed '/^CROSS/ s%$$%$$(shell if [ -n "$${CROSS_PREFIX}" ] ; then echo $${CROSS_PREFIX} ; else echo "'`echo ${NTNTNTNTI| sed 's/gcc$$//'`'" ; fi)% ' \
###			> Makefile || exit 1 ;\
###		[ -r busybox.mkll.OLD ] || mv busybox.mkll busybox.mkll.OLD || exit 1 ;\
###		cat busybox.mkll.OLD \
###			| sed	's%^gcc%'${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc'%' \
###			> busybox.mkll || exit 1 \
###	) || exit 1
##
##
#### ,-----
#### |	Build [xdc]
#### +-----
###
###${EXTTEMP}/${BUSYBOX_PATH}-xdc/busybox:
###	${MAKE} ${EXTTEMP}/${BUSYBOX_PATH}-xdc/Makefile
###	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
###		make CROSS_PREFIX=`echo ${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc | sed 's/gcc$$//'` \
###			|| exit 1 \
###	) || exit 1
###
###
#### ,-----
#### |	Install [xdc]
#### +-----
###
###${BUSYBOX_INSTTEMP}/bin/busybox:
###	${MAKE} ${EXTTEMP}/${BUSYBOX_PATH}-xdc/busybox
###	mkdir -p ${BUSYBOX_INSTTEMP}
###	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
###		make PREFIX=${BUSYBOX_INSTTEMP} install || exit 1 \
###	) || exit 1
###
###${TOPLEV}/${BUSYBOX_EGPNAME}.egp:
###	${MAKE} ${BUSYBOX_INSTTEMP}/bin/busybox
###	${PCREATE_SCRIPT} create ${TOPLEV}/${BUSYBOX_EGPNAME}.egp ${BUSYBOX_INSTTEMP}
###
###${XDC_ROOT}/bin/busybox: ${TOPLEV}/${BUSYBOX_EGPNAME}.egp
###	mkdir -p ${XDC_ROOT}
###	${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${BUSYBOX_EGPNAME}.egp
###
###REALCLEAN_TARGETS+= ${TOPLEV}/${BUSYBOX_EGPNAME}.egp
###
#### ,-----
#### |	Entry points [xdc]
#### +-----
###
###.PHONY: xdc-busybox
###ifeq (${MAKE_CHROOT},y)
###xdc-busybox: ${XDC_ROOT}/bin/busybox
###else
###xdc-busybox: ${TOPLEV}/${BUSYBOX_EGPNAME}.egp
###endif

.PHONY: all-NTI
#all-NTI: nti-busybox-extracted
#all-NTI: nti-busybox-configured
all-NTI: nti-busybox-built
# TODO: nti-busybox-installed
#	echo "INCOMPLETE" 1>&2 ; false
#
###endif	# HAVE_BUSYBOX_CONFIG
