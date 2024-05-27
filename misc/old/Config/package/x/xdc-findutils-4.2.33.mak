# findutils v4.2.33		[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-findutils' -- cross-userland findutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_FINDUTILS_SRC=${PKG_SRC}
CUI_FINDUTILS_TEMP=cui-findutils-${PKG_VER}

FUDGE_FINDUTILS_NATIVE_SPEC=${NATIVE_SPEC}
FUDGE_FINDUTILS_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_FINDUTILS_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_FINDUTILS_EXTRACTED=${EXTTEMP}/${CUI_FINDUTILS_TEMP}/Makefile

.PHONY: cui-findutils-extracted
cui-findutils-extracted: ${CUI_FINDUTILS_EXTRACTED}

${CUI_FINDUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} findutils-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_FINDUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_FINDUTILS_TEMP}
	mv ${EXTTEMP}/findutils-${PKG_VER} ${EXTTEMP}/${CUI_FINDUTILS_TEMP}


## ,-----
## |	package configure
## +-----

CUI_FINDUTILS_CONFIGURED=${EXTTEMP}/${CUI_FINDUTILS_TEMP}/config.status

.PHONY: cui-findutils-configured
cui-findutils-configured: cui-findutils-extracted ${CUI_FINDUTILS_CONFIGURED}

${CUI_FINDUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_FINDUTILS_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_FINDUTILS_TARGET_SPEC}-gcc \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${FUDGE_FINDUTILS_TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			|| exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_FINDUTILS_BUILT=${EXTTEMP}/${CUI_FINDUTILS_TEMP}/find/find

.PHONY: cui-findutils-built
cui-findutils-built: cui-findutils-configured ${CUI_FINDUTILS_BUILT}

${CUI_FINDUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_FINDUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_FINDUTILS_INSTALLED=${FUDGE_FINDUTILS_INSTROOT}/usr/bin/find

.PHONY: cui-findutils-installed
cui-findutils-installed: cui-findutils-built ${CUI_FINDUTILS_INSTALLED}

${CUI_FINDUTILS_INSTALLED}:
	mkdir -p ${FUDGE_FINDUTILS_INSTROOT}
	( cd ${EXTTEMP}/${CUI_FINDUTILS_TEMP} || exit 1 ;\
		make DESTDIR=${FUDGE_FINDUTILS_INSTROOT} install-exec-recursive || exit 1 \
	) || exit 1

.PHONY: all-CUI
#all-CUI: cui-findutils-extracted
#all-CUI: cui-findutils-configured
#all-CUI: cui-findutils-built
all-CUI: cui-findutils-installed
