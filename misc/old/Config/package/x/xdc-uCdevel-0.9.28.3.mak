# xdc-uCdevel v0.9.28.3		[ since v0.9.??, c.????-??-?? ]
# last mod WmT, 2010-03-11      [ (c) and GPLv2 1999-2010 ]


## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'ultc-uCdevel' -- cross-userland uCdevel runtime"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

## ,-----
## |	package extract
## +-----

CUI_UCDEVEL_TEMP=cui-uCdevel-${PKG_VER}
CUI_UCDEVEL_EXTRACTED=${EXTTEMP}/${CUI_UCDEVEL_TEMP}/Makefile

FUDGE_UCDEVEL_INSTROOT=${EXTTEMP}/insttemp
FUDGE_UCDEVEL_HTC_GCC=i686-host-linux-uclibc-gcc

.PHONY: cui-uCdevel-extracted
cui-uCdevel-extracted: ${CUI_UCDEVEL_EXTRACTED}

${CUI_UCDEVEL_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
ifeq (${PKG_PATCHES},)
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC}
else
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
                for PF in uclibc/*patch ; do \
                        patch --batch -d uCdevel-${PKG_VER} -Np1 < $${PF} ;\
			rm -f ${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${CUI_UCDEVEL_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_UCDEVEL_TEMP}
	mv ${EXTTEMP}/uClibc-${PKG_VER} ${EXTTEMP}/${CUI_UCDEVEL_TEMP}


## ,-----
## |	package configure
## +-----

CUI_UCDEVEL_CONFIGURED=${EXTTEMP}/${CUI_UCDEVEL_TEMP}/.config

.PHONY: cui-uCdevel-configured
cui-uCdevel-configured: cui-uCdevel-extracted ${CUI_UCDEVEL_CONFIGURED}

# [0.9.28.3] KERNEL_SOURCE must include /Makefile or /include/linux/kernel.h
${CUI_UCDEVEL_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_UCDEVEL_TEMP} || exit 1 ;\
		cp ${TC_ROOT}/etc/uClibc-${PKG_VER}-config .config || exit 1 ;\
		\
		yes '' | make HOSTCC=${FUDGE_UCDEVEL_HTC_GCC} oldconfig || exit 1 \
	) || exit 1

#		cp /dev/null .config || exit 1 ;\
#		case ${PKG_VER} in \
#		0.9.28.3) \
#		echo 'KERNEL_SOURCE="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/"' >> .config \
#		;; \
#		0.9.30.2) \
#			echo 'KERNEL_HEADERS="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/include/"' >> .config \
#			;; \
#		esac ;\
#		echo 'SHARED_LIB_LOADER_PREFIX="/lib"' >> .config ;\
#		echo 'RUNTIME_PREFIX="/"' >> .config ;\
#		echo 'CROSS_COMPILER_PREFIX="'${CTI_ROOT}'/usr/bin/'${TARGET_MIN_SPEC}'-"' >> .config ;\
#		\
#		echo 'DEVEL_PREFIX="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/"' >> .config ;\
#		echo 'TARGET_ARCH="'${TARGET_CPU}'"' >> .config ;\
#		echo 'TARGET_'${TARGET_CPU}'=y' >> .config ;\
#		\
#		yes '' | make oldconfig || exit 1 ;\
#		mkdir -p ${TC_ROOT}/etc/ || exit 1 ;\
#		cp .config ${TC_ROOT}/etc/uCdevel-${PKG_VER}-config || exit 1 \
#	) || exit 1


## ,-----
## |	package build
## +-----

CUI_UCDEVEL_BUILT=${EXTTEMP}/${CUI_UCDEVEL_TEMP}/lib/libm.a

.PHONY: cui-uCdevel-built
cui-uCdevel-built: cui-uCdevel-configured ${CUI_UCDEVEL_BUILT}

# full 'make' because we have devel, headers natively
${CUI_UCDEVEL_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_UCDEVEL_TEMP} || exit 1 ;\
		${MAKE} || exit 1 \
	) || exit 1
# FUDGE: avoid 'ldd' variants for now
#		0.9.28*) \
			${MAKE} CROSS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}- utils || exit 1 \


## ,-----
## |	package install
## +-----

# TODO: handle 'ldd'

CUI_UCDEVEL_INSTALLED=${FUDGE_UCDEVEL_INSTROOT}/usr/lib/libc.a

.PHONY: cui-uCdevel-installed
cui-uCdevel-installed: cui-uCdevel-built ${CUI_UCDEVEL_INSTALLED}

${CUI_UCDEVEL_INSTALLED}:
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CUI_UCDEVEL_TEMP} || exit 1 ;\
 		${MAKE} PREFIX=${FUDGE_UCDEVEL_INSTROOT}/ DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_dev || exit 1 \
	) || exit 1
# FUDGE: avoid 'ldd' variants for now
#		0.9.28*) \
#			cp utils/ldd ${FUDGE_UCDEVEL_INSTROOT}/usr/bin || exit 1 \

.PHONY: all-CUI
#all-CUI: cui-uCdevel-extracted
#all-CUI: cui-uCdevel-configured
#all-CUI: cui-uCdevel-built
all-CUI: cui-uCdevel-installed
