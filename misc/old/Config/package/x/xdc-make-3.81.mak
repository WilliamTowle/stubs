# make v4.2.33			[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-make' -- cross-userland make"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_MAKE_SRC=${PKG_SRC}
CUI_MAKE_TEMP=cui-make-${PKG_VER}

FUDGE_MAKE_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_MAKE_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_MAKE_EXTRACTED=${EXTTEMP}/${CUI_MAKE_TEMP}/Makefile

.PHONY: cui-make-extracted
cui-make-extracted: ${CUI_MAKE_EXTRACTED}

${CUI_MAKE_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} make-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_MAKE_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_MAKE_TEMP}
	mv ${EXTTEMP}/make-${PKG_VER} ${EXTTEMP}/${CUI_MAKE_TEMP}


## ,-----
## |	package configure
## +-----

CUI_MAKE_CONFIGURED=${EXTTEMP}/${CUI_MAKE_TEMP}/config.status

.PHONY: cui-make-configured
cui-make-configured: cui-make-extracted ${CUI_MAKE_CONFIGURED}

${CUI_MAKE_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_MAKE_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_MAKE_TARGET_SPEC}-gcc \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | make 's/-gnulibc1//') \
			  --build=${FUDGE_MAKE_TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			|| exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_MAKE_BUILT=${EXTTEMP}/${CUI_MAKE_TEMP}/make

.PHONY: cui-make-built
cui-make-built: cui-make-configured ${CUI_MAKE_BUILT}

${CUI_MAKE_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_MAKE_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_MAKE_INSTALLED=${FUDGE_MAKE_INSTROOT}/usr/bin/make

.PHONY: cui-make-installed
cui-make-installed: cui-make-built ${CUI_MAKE_INSTALLED}

${CUI_MAKE_INSTALLED}:
	mkdir -p ${FUDGE_MAKE_INSTROOT}
	( cd ${EXTTEMP}/${CUI_MAKE_TEMP} || exit 1 ;\
		make DESTDIR=${FUDGE_MAKE_INSTROOT} install-exec-recursive || exit 1 ;\
		cd ${FUDGE_MAKE_INSTROOT}/usr/bin && ln -sf make gmake \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-make-extracted
#all-CUI: cui-make-configured
#all-CUI: cui-make-built
all-CUI: cui-make-installed
