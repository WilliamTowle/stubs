# xdc-uClibc v0.9.28.3		[ since v0.9.??, c.????-??-?? ]
# last mod WmT, 2010-03-11      [ (c) and GPLv2 1999-2010 ]


## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'ultc-uClibc' -- cross-userland uClibc runtime"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

## ,-----
## |	package extract
## +-----

CUI_UCLIBC_TEMP=cui-uClibc-${PKG_VER}
CUI_UCLIBC_EXTRACTED=${EXTTEMP}/${CUI_UCLIBC_TEMP}/Makefile

FUDGE_UCLIBC_INSTROOT=${EXTTEMP}/insttemp
FUDGE_UCLIBC_HTC_GCC=i686-host-linux-uclibc-gcc

.PHONY: cui-uClibc-extracted
cui-uClibc-extracted: ${CUI_UCLIBC_EXTRACTED}

${CUI_UCLIBC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	[ ! -r ${EXTTEMP}/${CUI_UCLIBC_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_UCLIBC_TEMP}
ifneq (${PKG_PATCHES},)
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
                for PF in patch/*patch ; do \
                        patch --batch -d uClibc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f ${PF} ;\
		done \
	)
endif
	mv ${EXTTEMP}/uClibc-${PKG_VER} ${EXTTEMP}/${CUI_UCLIBC_TEMP}


## ,-----
## |	package configure
## +-----

CUI_UCLIBC_CONFIGURED=${EXTTEMP}/${CUI_UCLIBC_TEMP}/.config

.PHONY: cui-uClibc-configured
cui-uClibc-configured: cui-uClibc-extracted ${CUI_UCLIBC_CONFIGURED}

# [0.9.28.3] KERNEL_SOURCE must include /Makefile or /include/linux/kernel.h
${CUI_UCLIBC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_UCLIBC_TEMP} || exit 1 ;\
		cp ${TC_ROOT}/etc/lching/uClibc-0.9.28.3-config ${EXTTEMP}/${CUI_UCLIBC_TEMP}/.config || exit 1 ;\
		\
		yes '' | make HOSTCC=${FUDGE_UCLIBC_HTC_GCC} oldconfig || exit 1 \
		mkdir -p ${TC_ROOT}/etc/ || exit 1; \
		cp .config ${TC_ROOT}/etc/uClibc-${PKG_VER}-config || exit 1 \
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
#		cp .config ${TC_ROOT}/etc/uClibc-${PKG_VER}-config || exit 1 \
#	) || exit 1


## ,-----
## |	package build
## +-----

CUI_UCLIBC_BUILT=${EXTTEMP}/${CUI_UCLIBC_TEMP}/lib/libm.a

.PHONY: cui-uClibc-built
cui-uClibc-built: cui-uClibc-configured ${CUI_UCLIBC_BUILT}

# full 'make' because we have libc, headers natively
${CUI_UCLIBC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_UCLIBC_TEMP} || exit 1 ;\
		make || exit 1 \
	)
# FUDGE: avoid 'ldd' variants for now
#		0.9.28*) \
#			${MAKE} -C utils ldd.host \


## ,-----
## |	package install
## +-----

# TODO: handle 'ldd'

CUI_UCLIBC_INSTALLED=${FUDGE_UCLIBC_INSTROOT}/lib/ld-uClibc.so.0

.PHONY: cui-uClibc-installed
cui-uClibc-installed: cui-uClibc-built ${CUI_UCLIBC_INSTALLED}

${CUI_UCLIBC_INSTALLED}:
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CUI_UCLIBC_TEMP} || exit 1 ;\
	  	make RUNTIME_PREFIX=${FUDGE_UCLIBC_INSTROOT}'/' install_runtime || exit 1 \
	)


.PHONY: all-CUI
#all-CUI: cui-uClibc-extracted
#all-CUI: cui-uClibc-configured
#all-CUI: cui-uClibc-built
all-CUI: cui-uClibc-installed
