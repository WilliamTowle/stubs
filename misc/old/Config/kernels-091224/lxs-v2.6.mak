# linux source 2.6.20.1		[ since 2.0.37pre10 ]
# last mod WmT, 28/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

LXSOURCE_PKG:=lxsource
#LXSOURCE_VER:=2.2.26
#LXHEADERS_VER:=2.4.34.1
LXSOURCE_VER=2.6.20.1

LXSOURCE_SRC:=
LXSOURCE_SRC+=${SOURCEROOT}/l/linux-${LXSOURCE_VER}.tar.bz2
#LXSOURCE_SRC+=${SOURCEROOT}/l/linux-${LXSOURCE_VER}.tar.gz

LXSOURCE_PATH:=linux-${LXSOURCE_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/kernel/v2.6/linux-2.6.20.1.tar.bz2

#DEPS:=

# ,-----
# |	Configure [xtc]
# +-----

#HAVE_OWN_BASH=$(shell if [ -x ${HTC_ROOT}/bin/bash ] ; then echo y ; else echo n ; fi)

LXSOURCE_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')

ifeq (${TARGET_CPU},mipsel)
LXSOURCE_ARCH_OPTS:=ARCH=mips
else
LXSOURCE_ARCH_OPTS:=ARCH=${TARGET_CPU}
endif

LXSOURCE_ARCH_OPTS+= CROSS_COMPILE=${XTC_ROOT}/usr/bin/${LXHEADERS_TARGET_SPEC}-
LXSOURCE_ARCH_OPTS+= CONFIG_SHELL=${CONFIG_SHELL}

ifeq (${ETCDIR},)
ETCDIR:=${XTC_ROOT}/etc
endif

#GCC2723:=${XTC_ROOT}/usr/bin/i386-linux-2.7.2.3-gnu-kgcc
#GCC2723INC:=$(shell ${GCC2723} -v 2>&1 | grep specs | sed 's/.* //' | sed 's/specs/include/')

${EXTTEMP}/lxsource-${LXSOURCE_VER}/.config:
	[ ! -d ${EXTTEMP}/${LXSOURCE_PATH} ] || rm -rf ${EXTTEMP}/${LXSOURCE_PATH}
	${MAKE} extract LIST="$(strip ${LXSOURCE_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${LXSOURCE_PKG}*patch ; do \
#			cat $${PF} | ( cd ${LXSOURCE_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/lxsource-${LXSOURCE_VER} ] || rm -rf ${EXTTEMP}/lxsource-${LXSOURCE_VER}
	mv ${EXTTEMP}/${LXSOURCE_PATH} ${EXTTEMP}/lxsource-${LXSOURCE_VER}
	( cd ${EXTTEMP}/lxsource-${LXSOURCE_VER} || exit 1 ;\
		case ${LXSOURCE_VER}-${TARGET_CPU} in \
		2.0.*-i386) \
			sed 's%</dev/tty%%' scripts/Configure > scripts/Configure.auto || exit 1 ;\
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
 			cat Makefile.OLD \
				| sed	' s%scripts/Configure%scripts/Configure.auto% ' > Makefile || exit 1 \
 		;; \
		2.[24].*-i386) \
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
			cat Makefile.OLD \
				| sed '/^HOSTCC[ 	]=/	s%gcc%'${HTC_GCC}'%' \
				> Makefile || exit 1 ;\
			[ -r arch/i386/boot/Makefile.OLD ] || mv arch/i386/boot/Makefile arch/i386/boot/Makefile.OLD || exit 1 ;\
			cat arch/i386/boot/Makefile.OLD \
				| sed '/^..86[ 	]=/	s%$$(CROSS_COMPILE)%'${HTC_ROOT}'/usr/bin/%' \
				> arch/i386/boot/Makefile || exit 1 \
		;; \
		2.6.*-i386) \
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
			cat Makefile.OLD \
				| sed '/^HOSTCC[ 	]=/	s%gcc%'${HTC_GCC}'%' \
				> Makefile || exit 1 \
		;; \
		2.6.*-mips*) ;; \
		*) \
			echo "[CONFIGURE] VERSION/TARGET_CPU '${LXSOURCE_VER}'/'${TARGET_CPU}'" 1>&2 ;\
			exit 1 \
		;; \
		esac ;\
		make ${LXSOURCE_ARCH_OPTS} mrproper || exit 1 ;\
		cp ${ETCDIR}/linux-${LXSOURCE_VER}-config .config || exit 1 ;\
		case "${LXSOURCE_VER}" in \
		2.[04].*) \
			yes '' | make ${LXSOURCE_ARCH_OPTS} symlinks oldconfig dep || exit 1 \
		;; \
		2.2.26) \
			yes '' | make ${LXSOURCE_ARCH_OPTS} symlinks oldconfig dep || exit 1 ;\
			touch include/linux/autoconf.h \
 		;; \
		2.6.*) \
			yes '' | make ${LXSOURCE_ARCH_OPTS} oldconfig archprepare || exit 1 \
		;; \
		*) \
			echo "Unexpected VERSION/TARGET_CPU '${LXSOURCE_VER}'/'${TARGET_CPU}'" 1>&2 ;\
			exit 1 \
 		;; \
		esac \
	) || exit 1
#lx2.0:	touch include/linux/autoconf.h after make 'symlinks'?


# ,-----
# |	Build [xtc]
# +-----

# zImage/bzImage; modules; modules_install
# 2.6 kernel: no 'symlinks' target
${EXTTEMP}/lxsource-${LXSOURCE_VER}/.built: ${EXTTEMP}/lxsource-${LXSOURCE_VER}/.config
	( cd ${EXTTEMP}/lxsource-${LXSOURCE_VER} || exit 1 ;\
		case ${LXSOURCE_VER}-${TARGET_CPU} in \
		2.0.*-*) \
			rm scripts/mkdep >/dev/null 2>&1 ;\
			make HOSTCC=${GCC2723} dep || exit 1 ;\
			for TGT in modules bzImage ; do \
				make CC="${GCC2723} -D__KERNEL__ -nostdinc -I"`pwd`"/include -I${GCC2723INC}" CFLAGS='-O2 -fomit-frame-pointer' $${TGT} || exit 1 ;\
			done || exit 1 \
		;; \
		*-i386) \
			make ${LXSOURCE_ARCH_OPTS} bzImage || exit 1 ;\
		;; \
		*-*) \
			make ${LXSOURCE_ARCH_OPTS} || exit 1 \
		;; \
		esac \
	) || exit 1
	touch ${EXTTEMP}/lxsource-${LXSOURCE_VER}/.built


# ,-----
# |	Install [xtc]
# +-----

${ETCDIR}/vmlinuz-${LXSOURCE_VER}:
	${MAKE} ${EXTTEMP}/lxsource-${LXSOURCE_VER}/.built
	mkdir -p ${ETCDIR}
	( cd ${EXTTEMP}/lxsource-${LXSOURCE_VER} || exit 1 ;\
		case ${TARGET_CPU} in \
		i386) \
			cp arch/i386/boot/bzImage ${ETCDIR}/vmlinuz-${LXSOURCE_VER} || exit 1 ;\
		;; \
		*) \
			cp vmlinux ${ETCDIR}/vmlinux-${LXSOURCE_VER} || exit 1 ;\
		;; \
		esac \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade lxsource ${LXSOURCE_VER}
endif

# ,-----
# |	Entry points [xtc]
# +-----

.PHONY: xtc-lxsource
xtc-lxsource: ${ETCDIR}/vmlinuz-${LXSOURCE_VER}
