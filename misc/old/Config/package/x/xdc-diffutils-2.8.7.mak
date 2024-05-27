# diffutils v2.8.7		[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-diffutils' -- cross-userland diffutils"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_DIFFUTILS_SRC=${PKG_SRC}
CUI_DIFFUTILS_TEMP=cui-diffutils-${PKG_VER}

FUDGE_DIFFUTILS_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_DIFFUTILS_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_DIFFUTILS_EXTRACTED=${EXTTEMP}/${CUI_DIFFUTILS_TEMP}/Makefile

.PHONY: cui-diffutils-extracted
cui-diffutils-extracted: ${CUI_DIFFUTILS_EXTRACTED}

${CUI_DIFFUTILS_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} diffutils-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_DIFFUTILS_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_DIFFUTILS_TEMP}
	mv ${EXTTEMP}/diffutils-${PKG_VER} ${EXTTEMP}/${CUI_DIFFUTILS_TEMP}


## ,-----
## |	package configure
## +-----

CUI_DIFFUTILS_CONFIGURED=${EXTTEMP}/${CUI_DIFFUTILS_TEMP}/config.status

.PHONY: cui-diffutils-configured
cui-diffutils-configured: cui-diffutils-extracted ${CUI_DIFFUTILS_CONFIGURED}

${CUI_DIFFUTILS_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_DIFFUTILS_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_DIFFUTILS_TARGET_SPEC}-gcc \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${FUDGE_DIFFUTILS_TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			|| exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_DIFFUTILS_BUILT=${EXTTEMP}/${CUI_DIFFUTILS_TEMP}/src/cmp

.PHONY: cui-diffutils-built
cui-diffutils-built: cui-diffutils-configured ${CUI_DIFFUTILS_BUILT}

${CUI_DIFFUTILS_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_DIFFUTILS_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_DIFFUTILS_INSTALLED=${FUDGE_DIFFUTILS_INSTROOT}/usr/bin/cmp

.PHONY: cui-diffutils-installed
cui-diffutils-installed: cui-diffutils-built ${CUI_DIFFUTILS_INSTALLED}

${CUI_DIFFUTILS_INSTALLED}:
	mkdir -p ${FUDGE_DIFFUTILS_INSTROOT}
	( cd ${EXTTEMP}/${CUI_DIFFUTILS_TEMP} || exit 1 ;\
		make DESTDIR=${FUDGE_DIFFUTILS_INSTROOT} install-exec-recursive || exit 1 \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-diffutils-extracted
#all-CUI: cui-diffutils-configured
#all-CUI: cui-diffutils-built
all-CUI: cui-diffutils-installed
