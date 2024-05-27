# diffutils v2.8.7		[ since v2.8.1, c.2002-10-09 ]
# last mod WmT, 2009-09-14	[ (c) and GPLv2 1999-2009 ]

#DESCRLIST+= "'nti-diffutils' -- host-toolchain diffutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_DIFFUTILS_TEMP=nti-diffutils-${PKG_VER}
NTI_DIFFUTILS_EXTRACTED=${EXTTEMP}/${NTI_DIFFUTILS_TEMP}/configure

.PHONY: nti-diffutils-extracted
nti-diffutils-extracted: ${NTI_DIFFUTILS_EXTRACTED}

${NTI_DIFFUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} diffutils-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_DIFFUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_DIFFUTILS_TEMP}
	mv ${EXTTEMP}/diffutils-${PKG_VER} ${EXTTEMP}/${NTI_DIFFUTILS_TEMP}


## ,-----
## |	package configure
## +-----

NTI_DIFFUTILS_CONFIGURED=${EXTTEMP}/${NTI_DIFFUTILS_TEMP}/config.status

.PHONY: nti-diffutils-configured
nti-diffutils-configured: nti-diffutils-extracted ${NTI_DIFFUTILS_CONFIGURED}

${NTI_DIFFUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_DIFFUTILS_TEMP} || exit 1 ;\
	  ./configure \
	  	--prefix=${NTI_ROOT}/usr \
		|| exit 1 \
	)


## ,-----
## |	package build
## +-----

NTI_DIFFUTILS_BUILT=${EXTTEMP}/${NTI_DIFFUTILS_TEMP}/src/diff

.PHONY: nti-diffutils-built
nti-diffutils-built: nti-diffutils-configured ${NTI_DIFFUTILS_BUILT}

${NTI_DIFFUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_DIFFUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	)

## ,-----
## |	package install
## +-----

NTI_DIFFUTILS_INSTALLED=${NTI_ROOT}/usr/bin/diff

.PHONY: nti-diffutils-installed
nti-diffutils-installed: nti-diffutils-built ${NTI_DIFFUTILS_INSTALLED}

${NTI_DIFFUTILS_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_DIFFUTILS_TEMP} || exit 1 ;\
		make install \
	)

.PHONY: all-NTI
all-NTI: nti-diffutils-installed
