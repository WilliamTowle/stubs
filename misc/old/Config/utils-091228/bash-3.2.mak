# bash 3.2			[ EARLIEST v2.05a, c.2002-10-21 ]
# last mod WmT, 2009-12-24	[ (c) and GPLv2 1999-2009 ]

include ${TOPLEV}/Config/platform-bt.mak

#ifneq (${HAVE_BASH_CONFIG},y)
#HAVE_BASH_CONFIG:=y
#
#include ${TOPLEV}/Config/nti-boot/diffutils/v2.8.7.mak
#
#DESCRLIST+= "'nti-bash' -- GNU's Bourne Again SHell"
#
## ,-----
## |	Settings
## +-----
#
#BASH_PKG:=bash
#BASH_VER:=2.05b

NTI_BASH_SRC+= ${PKG_SRC}

URLS+= ${PKG_URLS}

## ,-----
## |	package extract
## +-----

NTI_BASH_TEMP=nti-bash-${PKG_VER}
NTI_BASH_EXTRACTED=${EXTTEMP}/${NTI_BASH_TEMP}/configure

.PHONY: nti-bash-extracted
nti-bash-extracted: ${NTI_BASH_EXTRACTED}

${NTI_BASH_EXTRACTED}:
	${SCRIPTBIN}/extract ${EXTTEMP} bash-${PKG_VER} ${NTI_BASH_SRC}
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
#	  	CC=${NATIVE_GCC} \
#	    	  CFLAGS=-O2 \
#			./configure \
#			  --prefix=${NTI_ROOT}/usr \
#			  --bindir=${NTI_ROOT}/bin \
#			  --enable-alias \
#			  --disable-readline \
#			  --without-curses \
#			  --without-bash-malloc \
#			  --disable-largefile --disable-nls \
#			  || exit 1 \
#	)	|| exit 1
#
#
### ,-----
### |	Build [htc]
### +-----
##
##${EXTTEMP}/${BASH_PATH}-htc/bash: ${EXTTEMP}/${BASH_PATH}-htc/Makefile
##	( cd ${EXTTEMP}/${BASH_PATH}-htc || exit 1 ;\
##		make || exit 1 \
##	) || exit 1
##
##
### ,-----
### |	Install [htc]
### +-----
##
##${NTI_ROOT}/bin/bash:
##	${MAKE} ${EXTTEMP}/${BASH_PATH}-htc/bash
##	( cd ${EXTTEMP}/${BASH_PATH}-htc || exit 1 ;\
##		make install || exit 1 \
##	) || exit 1
##ifeq (${HAVE_PTRACKING},y)
##	DBROOT=${NTI_ROOT} ${PTRACK_SCRIPT} upgrade ${BASH_PKG} ${PKG_VER}
##endif
##
### ,-----
### |	Entry Points [htc]
### +-----
#
#.PHONY: nti-bash
#nti-bash: nti-bash-installed nti-bash-installed
#
#NTI_TARGETS+= ntntiash
#
#endif	# HAVE_BASH_CONFIG
## diffutils v2.8.7		[ since v2.8.1, c.2002-10-09 ]
## last mod WmT, 2009-09-14	[ (c) and GPLv2 1999-2009 ]
#
##DESCRLIST+= "'nti-diffutils' -- host-toolchain diffutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


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
