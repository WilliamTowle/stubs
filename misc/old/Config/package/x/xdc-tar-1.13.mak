# tar v1.13			[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-tar' -- cross-userland tar"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_TAR_SRC=${PKG_SRC}
CUI_TAR_TEMP=cui-tar-${PKG_VER}

FUDGE_TAR_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_TAR_INSTROOT=${EXTTEMP}/insttemp


## ,-----
## |	package extract
## +-----

CUI_TAR_EXTRACTED=${EXTTEMP}/${CUI_TAR_TEMP}/Makefile

.PHONY: cui-tar-extracted
cui-tar-extracted: ${CUI_TAR_EXTRACTED}

${CUI_TAR_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} tar-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_TAR_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_TAR_TEMP}
	mv ${EXTTEMP}/tar-${PKG_VER} ${EXTTEMP}/${CUI_TAR_TEMP}


## ,-----
## |	package configure
## +-----

CUI_TAR_CONFIGURED=${EXTTEMP}/${CUI_TAR_TEMP}/config.status

.PHONY: cui-tar-configured
cui-tar-configured: cui-tar-extracted ${CUI_TAR_CONFIGURED}

${CUI_TAR_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_TAR_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_TAR_TARGET_SPEC}-gcc \
		  CFLAGS=-O2 \
			./configure --prefix=/usr --bindir=/bin \
			  --host=$(shell echo ${NATIVE_SPEC} | tar 's/-gnulibc1//') \
			  --build=${FUDGE_TAR_TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			|| exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_TAR_BUILT=${EXTTEMP}/${CUI_TAR_TEMP}/src/tar

.PHONY: cui-tar-built
cui-tar-built: cui-tar-configured ${CUI_TAR_BUILT}

${CUI_TAR_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_TAR_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_TAR_INSTALLED=${FUDGE_TAR_INSTROOT}/bin/tar

.PHONY: cui-tar-installed
cui-tar-installed: cui-tar-built ${CUI_TAR_INSTALLED}

${CUI_TAR_INSTALLED}:
	mkdir -p ${FUDGE_TAR_INSTROOT}
	( cd ${EXTTEMP}/${CUI_TAR_TEMP} || exit 1 ;\
		make DESTDIR=${FUDGE_TAR_INSTROOT} install-exec-recursive || exit 1 \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-tar-extracted
#all-CUI: cui-tar-configured
#all-CUI: cui-tar-built
all-CUI: cui-tar-installed
