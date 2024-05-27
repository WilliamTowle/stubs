# sed v4.2.33			[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-sed' -- cross-userland sed"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_SED_SRC=${PKG_SRC}
CUI_SED_TEMP=cui-sed-${PKG_VER}

FUDGE_SED_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_SED_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_SED_EXTRACTED=${EXTTEMP}/${CUI_SED_TEMP}/Makefile

.PHONY: cui-sed-extracted
cui-sed-extracted: ${CUI_SED_EXTRACTED}

${CUI_SED_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} sed-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_SED_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_SED_TEMP}
	mv ${EXTTEMP}/sed-${PKG_VER} ${EXTTEMP}/${CUI_SED_TEMP}


## ,-----
## |	package configure
## +-----

CUI_SED_CONFIGURED=${EXTTEMP}/${CUI_SED_TEMP}/config.status

.PHONY: cui-sed-configured
cui-sed-configured: cui-sed-extracted ${CUI_SED_CONFIGURED}

${CUI_SED_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_SED_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_SED_TARGET_SPEC}-gcc \
		  CFLAGS=-O2 \
			./configure --prefix=/usr --bindir=/bin \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${FUDGE_SED_TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			|| exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_SED_BUILT=${EXTTEMP}/${CUI_SED_TEMP}/sed/sed

.PHONY: cui-sed-built
cui-sed-built: cui-sed-configured ${CUI_SED_BUILT}

${CUI_SED_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_SED_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_SED_INSTALLED=${FUDGE_SED_INSTROOT}/bin/sed

.PHONY: cui-sed-installed
cui-sed-installed: cui-sed-built ${CUI_SED_INSTALLED}

${CUI_SED_INSTALLED}:
	mkdir -p ${FUDGE_SED_INSTROOT}
	( cd ${EXTTEMP}/${CUI_SED_TEMP} || exit 1 ;\
		make DESTDIR=${FUDGE_SED_INSTROOT} install-exec-recursive || exit 1 \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-sed-extracted
#all-CUI: cui-sed-configured
#all-CUI: cui-sed-built
all-CUI: cui-sed-installed
