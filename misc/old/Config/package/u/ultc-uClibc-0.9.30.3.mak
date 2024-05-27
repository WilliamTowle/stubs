# ultc-uClibc v0.9.30.3		[ since v0.9.??, c.????-??-?? ]
# last mod WmT, 2010-01-27      [ (c) and GPLv2 1999-2010 ]


## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'ultc-uClibc' -- userland toolchain uClibc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_ULTC_UCLIBC_TEMP=cti-ultc_uClibc-${PKG_VER}
CTI_ULTC_UCLIBC_EXTRACTED=${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP}/Makefile

.PHONY: cti-ultc_uClibc-extracted
cti-ultc_uClibc-extracted: ${CTI_ULTC_UCLIBC_EXTRACTED}

${CTI_ULTC_UCLIBC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
ifeq (${PKG_PATCHES},)
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC}
else
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
                for PF in uclibc/*patch ; do \
                        patch --batch -d ultc_uClibc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f ${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP}
	mv ${EXTTEMP}/uClibc-${PKG_VER} ${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP}


## ,-----
## |	package configure
## +-----

CTI_ULTC_UCLIBC_CONFIGURED=${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP}/.config

.PHONY: cti-ultc_uClibc-configured
cti-ultc_uClibc-configured: cti-ultc_uClibc-extracted ${CTI_ULTC_UCLIBC_CONFIGURED}

${CTI_ULTC_UCLIBC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP} || exit 1 ;\
		cp /dev/null .config || exit 1 ;\
		echo 'KERNEL_HEADERS="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/include/"' >> .config ;\
		echo 'SHARED_LIB_LOADER_PREFIX="/lib"' >> .config ;\
		echo 'RUNTIME_PREFIX="/"' >> .config ;\
		echo 'CROSS_COMPILER_PREFIX="'${CTI_ROOT}'/usr/bin/'${TARGET_MIN_SPEC}'-"' >> .config ;\
		\
		echo 'DEVEL_PREFIX="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/"' >> .config ;\
		echo 'TARGET_ARCH="'${TARGET_CPU}'"' >> .config ;\
		echo 'TARGET_'${TARGET_CPU}'=y' >> .config ;\
		\
		yes '' | make oldconfig || exit 1 ;\
		mkdir -p ${CTI_ROOT}/etc/ || exit 1;\
		cp .config ${CTI_ROOT}/etc/uClibc-${PKG_VER}-config || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_ULTC_UCLIBC_BUILT=${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP}/lib/libm.a

.PHONY: cti-ultc_uClibc-built
cti-ultc_uClibc-built: cti-ultc_uClibc-configured ${CTI_ULTC_UCLIBC_BUILT}

# full 'make' because we have libc, headers natively
${CTI_ULTC_UCLIBC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP} || exit 1 ;\
		make || exit 1 \
	)
#		0.9.28*) \
#			${MAKE} -C utils ldd.host \


## ,-----
## |	package install
## +-----

CTI_ULTC_UCLIBC_INSTALLED=${CTI_ROOT}/usr/${TARGET_SPEC}/usr/lib/libm.a

.PHONY: cti-ultc_uClibc-installed
cti-ultc_uClibc-installed: cti-ultc_uClibc-built ${CTI_ULTC_UCLIBC_INSTALLED}

${CTI_ULTC_UCLIBC_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_ULTC_UCLIBC_TEMP} || exit 1 ;\
		case ${PKG_VER} in \
		0.9.30.2) \
			CDPATH='' make install_dev || exit 1 ;\
	  		CDPATH='' make RUNTIME_PREFIX="${CTI_ROOT}/usr/${TARGET_SPEC}/usr/" install_runtime || exit 1 \
		;; \
		*) \
			make install_dev || exit 1 ;\
	  		make RUNTIME_PREFIX="${CTI_ROOT}/usr/${TARGET_SPEC}/usr/" install_runtime || exit 1 \
		;; \
		esac \
	)


.PHONY: all-CTI
all-CTI: cti-ultc_uClibc-installed
