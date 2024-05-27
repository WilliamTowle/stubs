# bzip2 v2.8.7		[ since v2.8.1, c.2002-10-09 ]
# last mod WmT, 2009-09-14	[ (c) and GPLv2 1999-2009 ]

#DESCRLIST+= "'nti-bzip2' -- host-toolchain bzip2"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_BZIP2_TEMP=nti-bzip2-${PKG_VER}
NTI_BZIP2_EXTRACTED=${EXTTEMP}/${NTI_BZIP2_TEMP}/Makefile

.PHONY: nti-bzip2-extracted
nti-bzip2-extracted: ${NTI_BZIP2_EXTRACTED}

${NTI_BZIP2_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} bzip2-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_BZIP2_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_BZIP2_TEMP}
	mv ${EXTTEMP}/bzip2-${PKG_VER} ${EXTTEMP}/${NTI_BZIP2_TEMP}


## ,-----
## |	package configure
## +-----

NTI_BZIP2_CONFIGURED=${EXTTEMP}/${NTI_BZIP2_TEMP}/Makefile.OLD

.PHONY: nti-bzip2-configured
nti-bzip2-configured: nti-bzip2-extracted ${NTI_BZIP2_CONFIGURED}

${NTI_BZIP2_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_BZIP2_TEMP} || exit 1 ;\
		mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^CC/		s%=.*%='${NATIVE_GCC}'%' \
			| sed '/^BIGFILES/	s/^/#/' \
			| sed '/^PREFIX/	s%/usr/local%'${NTI_ROOT}'/usr%' \
			> Makefile || exit 1 \
	)


## ,-----
## |	package build
## +-----

NTI_BZIP2_BUILT=${EXTTEMP}/${NTI_BZIP2_TEMP}/bzip2recover

.PHONY: nti-bzip2-built
nti-bzip2-built: nti-bzip2-configured ${NTI_BZIP2_BUILT}

${NTI_BZIP2_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_BZIP2_TEMP} || exit 1 ;\
		make || exit 1 \
	)

## ,-----
## |	package install
## +-----

NTI_BZIP2_INSTALLED=${NTI_ROOT}/usr/bin/bzip2recover

.PHONY: nti-bzip2-installed
nti-bzip2-installed: nti-bzip2-built ${NTI_BZIP2_INSTALLED}

${NTI_BZIP2_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_BZIP2_TEMP} || exit 1 ;\
		make install \
	)

.PHONY: all-NTI
all-NTI: nti-bzip2-installed
