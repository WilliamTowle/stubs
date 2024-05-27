# uhtc-gcc v2.95.3		[ since v2.7.2.3 c.2002-10-14 ]
# last mod WmT, 2010-06-02	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'uhtc-gcc' -- host gcc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_GCC_TEMP=nti-gcc-${PKG_VER}
NTI_GCC_EXTRACTED=${EXTTEMP}/${NTI_GCC_TEMP}/configure

.PHONY: nti-gcc-extracted
nti-gcc-extracted: ${NTI_GCC_EXTRACTED}

${NTI_GCC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} gcc-2.95.3 ${PKG_SRC} ${PKG_PATCHES}
ifneq (${PKG_PATCHES},)
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in patch/*patch ; do \
			echo "*** PATCHING -- $${PF} ***" ;\
			grep '+++' $${PF} ;\
			patch --batch -d gcc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${NTI_GCC_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_GCC_TEMP}
	mv ${EXTTEMP}/gcc-2.95.3 ${EXTTEMP}/${NTI_GCC_TEMP}


## ,-----
## |	package configure
## +-----

NTI_GCC_CONFIGURED=${EXTTEMP}/${NTI_GCC_TEMP}/config.status

.PHONY: nti-gcc-configured
nti-gcc-configured: nti-gcc-extracted ${NTI_GCC_CONFIGURED}

# gcc v2.95.3 lacks native support for '*-*-*-uclibc' target:         
NTI_GCC_PROVIDER_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/uclibc$$/gnu/')

# 1. adjust target= to suit supported targets
# 2. --program-transform-name ensures desired executable prefix
${NTI_GCC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_GCC_TEMP} || exit 1 ;\
	  CC=${NATIVE_CC} \
	    AR=$(shell echo ${NATIVE_CC} | sed 's/g*cc$$/ar/') \
	    CFLAGS='-O2' \
		./configure -v \
			--prefix=${NTI_ROOT}/usr \
			--host=${NTI_GCC_PROVIDER_SPEC} \
			--build=${NTI_GCC_PROVIDER_SPEC} \
			--target=${NTI_GCC_PROVIDER_SPEC} \
			--program-transform-name='s,^,'${NATIVE_SPEC}'-,' \
			--with-local-prefix=${NTI_ROOT}/usr \
			--enable-languages=c \
			--disable-nls \
			--enable-shared \
			|| exit 1 \
	)


## ,-----
## |	package build
## +-----

NTI_GCC_BUILT=${EXTTEMP}/${NTI_GCC_TEMP}/libiberty/libiberty.a

.PHONY: nti-gcc-built
nti-gcc-built: nti-gcc-configured ${NTI_GCC_BUILT}

# full 'make' because we have libc, headers natively
${NTI_GCC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_GCC_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

NTI_GCC_INSTALLED=${NTI_ROOT}/usr/bin/${NATIVE_SPEC}-gcc

.PHONY: nti-gcc-installed
nti-gcc-installed: nti-gcc-built ${NTI_GCC_INSTALLED}

${NTI_GCC_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_GCC_TEMP} || exit 1 ;\
		make install-gcc || exit 1 ;\
		case ${NATIVE_SPEC} in \
		*-uclibc) \
			cat gcc/specs \
				| sed   's/ld-linux.so.2/ld-uClibc.so.0/ ; /cross_compile/,+2 s/1/0/ ' \
				> ${NTI_ROOT}/usr/lib/gcc-lib/${NTI_GCC_PROVIDER_SPEC}/2.95.3/specs \
				|| exit 1 \
		;; \
		esac \
	) || exit 1


.PHONY: all-NTI
all-NTI: nti-gcc-installed
