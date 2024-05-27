# bash 2.05b			[ EARLIEST v2.05a, c.2002-10-21 ]
# last mod WmT, 2009-12-02	[ (c) and GPLv2 1999-2007 ]

## ,-----
## |	Settings
## +-----

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

#DESCRLIST+= "'nti-diffutils' -- host-toolchain diffutils"


## ,-----
## |	package extract
## +-----

NTI_BASH_TEMP=nti-bash-${PKG_VER}
NTI_BASH_EXTRACTED=${EXTTEMP}/${NTI_BASH_TEMP}/configure

.PHONY: nti-bash-extracted
nti-bash-extracted: ${NTI_BASH_EXTRACTED}

${NTI_BASH_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} bash-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_BASH_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_BASH_TEMP}
	mv ${EXTTEMP}/bash-${PKG_VER} ${EXTTEMP}/${NTI_BASH_TEMP}


### ,-----
### |	package configure
### +-----
#
#NTI_BASH_CONFIGURED=${EXTTEMP}/${NTI_BASH_TEMP}/config.status
#
#.PHONY: nti-bash-configured
#nti-bash-configured: nti-bash-extracted ${NTI_BASH_CONFIGURED}
#
#${NTI_BASH_CONFIGURED}:
#	echo "*** $@ (CONFIGURED) ***"
#	( cd ${EXTTEMP}/${NTI_BASH_TEMP} || exit 1 ;\
#	  ./configure \
#	  	--prefix=${NTI_ROOT}/usr \
#		|| exit 1 \
#	)
#
#
### ,-----
### |	package build
### +-----
#
#NTI_BASH_BUILT=${EXTTEMP}/${NTI_BASH_TEMP}/src/diff
#
#.PHONY: nti-bash-built
#nti-bash-built: nti-bash-configured ${NTI_BASH_BUILT}
#
#${NTI_BASH_BUILT}:
#	echo "*** $@ (BUILT) ***"
#	( cd ${EXTTEMP}/${NTI_BASH_TEMP} || exit 1 ;\
#		make || exit 1 \
#	)
#
### ,-----
### |	package install
### +-----
#
#NTI_BASH_INSTALLED=${NTI_ROOT}/usr/bin/diff
#
#.PHONY: nti-bash-installed
#nti-bash-installed: nti-bash-built ${NTI_BASH_INSTALLED}
#
#${NTI_BASH_INSTALLED}: ${NTI_ROOT}
#	echo "*** $@ (INSTALLED) ***"
#	( cd ${EXTTEMP}/${NTI_BASBASBASBASH
#		make install \
#	)

.PHONY: all-NTI
all-NTI: nti-bash-extracted
#all-NTI: nti-bash-configured
#all-NTI: nti-bash-built
#all-NTI: nti-bash-installed
