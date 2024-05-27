# legtc-uClibc v0.9.28.3	[ since v0.9.15, c.2002-10-14 ]
# last mod WmT, 2010-05-18      [ (c) and GPLv2 1999-2010 ]


## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'legtc-uClibc' -- userland toolchain uClibc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

CTI_TC_UCLIBC_TEMP=cti-tc_uClibc-${PKG_VER}
CTI_TC_UCLIBC_EXTRACTED=${EXTTEMP}/${CTI_TC_UCLIBC_TEMP}/Makefile

.PHONY: cti-tc_uClibc-extracted
cti-tc_uClibc-extracted: ${CTI_TC_UCLIBC_EXTRACTED}

${CTI_TC_UCLIBC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
ifneq (${PKG_PATCHES},)
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in patch/*patch ; do \
			echo "PATCHFILE $${PF}..." ;\
			patch --batch -d uClibc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${CTI_TC_UCLIBC_TEMP} ] || rm -rf ${EXTTEMP}/${CTI_TC_UCLIBC_TEMP}
	mv ${EXTTEMP}/uClibc-${PKG_VER} ${EXTTEMP}/${CTI_TC_UCLIBC_TEMP}


## ,-----
## |	package configure
## +-----

# v0.9.26: KERNEL_SOURCE because 'Makefile' access is required
# v0.9.30.2: KERNEL_HEADERS

CTI_TC_UCLIBC_CONFIGURED=${EXTTEMP}/${CTI_TC_UCLIBC_TEMP}/.config

.PHONY: cti-tc_uClibc-configured
cti-tc_uClibc-configured: cti-tc_uClibc-extracted ${CTI_TC_UCLIBC_CONFIGURED}

${CTI_TC_UCLIBC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CTI_TC_UCLIBC_TEMP} || exit 1 ;\
		cp /dev/null .config || exit 1 ;\
		case ${PKG_VER} in \
		0.9.26) \
			echo 'KERNEL_SOURCE="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/src/linux/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' ;\
			echo 'MALLOC=y' ;\
			echo 'MALLOC_STANDARD=y' \
		;; \
		0.9.28*) \
			echo 'KERNEL_SOURCE="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/src/linux/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'CROSS_COMPILER_PREFIX="'${CTI_ROOT}'/usr/bin/'${TARGET_MIN_SPEC}'-"' ;\
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' ;\
			echo '# UCLIBC_HAS_SHADOW is not set' ;\
			echo 'MALLOC=y' ;\
			echo 'MALLOC_STANDARD=y' \
		;; \
		0.9.30.2) \
			echo 'KERNEL_HEADERS="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/include/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'CROSS_COMPILER_PREFIX="'${CTI_ROOT}'/usr/bin/'${TARGET_MIN_SPEC}'-"' \
		;; \
		*) \
			echo "$0: do_configure: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac >> .config ;\
		\
		echo 'DEVEL_PREFIX="'${CTI_ROOT}'/usr/'${TARGET_SPEC}'/usr/"' >> .config ;\
		echo 'TARGET_ARCH="'${TARGET_CPU}'"' >> .config ;\
		echo 'TARGET_'${TARGET_CPU}'=y' >> .config ;\
		\
		case ${PKG_VER} in \
		0.9.26|0.9.28.*) \
			[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1 ;\
			cat Rules.mak.OLD \
				| sed	' /^CROSS/	s%=.*%= '${CTI_ROOT}'/usr/bin/'${TARGET_MIN_SPEC}'-% ; /(CROSS)/	s%$$(CROSS)%$$(shell if [ -n "$${CROSS}" ] ; then echo $${CROSS} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /USE_CACHE/ s/#// ; /usr.bin.*awk/ s%/usr/bin/awk%'${AWK_EXE}'% ' > Rules.mak || exit 1 \
		;; \
		*)	echo "$0: do_configure 'Makefile's: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac ;\
		yes '' | make oldconfig || exit 1 \
	)


## ,-----
## |	package build
## +-----

CTI_TC_UCLIBC_BUILT=${EXTTEMP}/${CTI_TC_UCLIBC_TEMP}/lib/libm.a

.PHONY: cti-tc_uClibc-built
cti-tc_uClibc-built: cti-tc_uClibc-configured ${CTI_TC_UCLIBC_BUILT}

# full 'make' because we have libc, headers natively
${CTI_TC_UCLIBC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CTI_TC_UCLIBC_TEMP} || exit 1 ;\
		make || exit 1 \
	)
#		0.9.28*) \
#			${MAKE} -C utils ldd.host \


## ,-----
## |	package install
## +-----

CTI_TC_UCLIBC_INSTALLED=${CTI_ROOT}/usr/${TARGET_SPEC}/usr/lib/libm.a

.PHONY: cti-tc_uClibc-installed
cti-tc_uClibc-installed: cti-tc_uClibc-built ${CTI_TC_UCLIBC_INSTALLED}

${CTI_TC_UCLIBC_INSTALLED}: ${CTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CTI_TC_UCLIBC_TEMP} || exit 1 ;\
		mkdir -p ${CTI_ROOT}/etc/ || exit 1;\
		cp .config ${CTI_ROOT}/etc/config-uClibc-${PKG_VER} || exit 1 ;\
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
#all-CTI: cti-tc_uClibc-extracted
#all-CTI: cti-tc_uClibc-configured
#all-CTI: cti-tc_uClibc-built
all-CTI: cti-tc_uClibc-installed
