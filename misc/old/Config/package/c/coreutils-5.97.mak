# coreutils v5.97		[ since v?.??, c.????-??-?? ]
# last mod WmT, 2009-12-24	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	Settings
## +-----

#DESCRLIST+= "'nti-coreutils' -- host-toolchain coreutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_COREUTILS_TEMP=nti-coreutils-${PKG_VER}
NTI_COREUTILS_EXTRACTED=${EXTTEMP}/${NTI_COREUTILS_TEMP}/configure

.PHONY: nti-coreutils-extracted
nti-coreutils-extracted: ${NTI_COREUTILS_EXTRACTED}

${NTI_COREUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} coreutils-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_COREUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_COREUTILS_TEMP}
	mv ${EXTTEMP}/coreutils-${PKG_VER} ${EXTTEMP}/${NTI_COREUTILS_TEMP}


## ,-----
## |	package configure
## +-----

NTI_COREUTILS_CONFIGURED=${EXTTEMP}/${NTI_COREUTILS_TEMP}/config.status

.PHONY: nti-coreutils-configured
nti-coreutils-configured: nti-coreutils-extracted ${NTI_COREUTILS_CONFIGURED}

# 1. [coreutils] '--without-included-regex' avoids MB_CUR_MAX issues
${NTI_COREUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_COREUTILS_TEMP} || exit 1 ;\
	  ./configure \
	  	 --prefix=${NTI_ROOT} \
	  	 --without-included-regex \
	  	 --disable-largefile --disable-nls \
		 --disable-dependency-tracking \
	)


## ,-----
## |	package build
## +-----

NTI_COREUTILS_BUILT=${EXTTEMP}/${NTI_COREUTILS_TEMP}/src/df
.PHONY: nti-coreutils-built
nti-coreutils-built: nti-coreutils-configured ${NTI_COREUTILS_BUILT}

${NTI_COREUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_COREUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

NTI_COREUTILS_INSTALLED=${NTI_ROOT}/bin/df

.PHONY: nti-coreutils-installed
nti-coreutils-installed: nti-coreutils-built ${NTI_COREUTILS_INSTALLED}

${NTI_COREUTILS_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_COREUTILS_TEMP} || exit 1 ;\
		make install-exec-recursive \
	)

.PHONY: all-NTI
all-NTI: nti-coreutils-installed
