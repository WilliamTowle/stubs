# grep v2.5.1a			[ since v?.??, c.????-??-?? ]
# last mod WmT, 2009-12-27	[ (c) and GPLv2 1999-2009 ]

## ,-----
## |	Settings
## +-----

#DESCRLIST+= "'nti-grep' -- host-toolchain grep"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_GREP_TEMP=nti-grep-${PKG_VER}
NTI_GREP_EXTRACTED=${EXTTEMP}/${NTI_GREP_TEMP}/configure

.PHONY: nti-grep-extracted
nti-grep-extracted: ${NTI_GREP_EXTRACTED}

${NTI_GREP_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} grep-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_GREP_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_GREP_TEMP}
	mv ${EXTTEMP}/grep-${PKG_VER} ${EXTTEMP}/${NTI_GREP_TEMP}


## ,-----
## |	package configure
## +-----

NTI_GREP_CONFIGURED=${EXTTEMP}/${NTI_GREP_TEMP}/config.status

.PHONY: nti-grep-configured
nti-grep-configured: nti-grep-extracted ${NTI_GREP_CONFIGURED}

${NTI_GREP_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_GREP_TEMP} || exit 1 ;\
	  ./configure \
	  	 --prefix=${NTI_ROOT} \
	  	 --disable-largefile --disable-nls \
	)


## ,-----
## |	package build
## +-----

NTI_GREP_BUILT=${EXTTEMP}/${NTI_GREP_TEMP}/src/grep
.PHONY: nti-grep-built
nti-grep-built: nti-grep-configured ${NTI_GREP_BUILT}

${NTI_GREP_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_GREP_TEMP} || exit 1 ;\
		make || exit 1 \
	)


## ,-----
## |	package install
## +-----

NTI_GREP_INSTALLED=${NTI_ROOT}/bin/grep

.PHONY: nti-grep-installed
nti-grep-installed: nti-grep-built ${NTI_GREP_INSTALLED}

${NTI_GREP_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_GREP_TEMP} || exit 1 ;\
		make install-exec-recursive \
	)

.PHONY: all-NTI
#all-NTI: nti-grep-extracted
#all-NTI: nti-grep-configured
#all-NTI: nti-grep-built
all-NTI: nti-grep-installed
