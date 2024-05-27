# uperl v5.8.9			[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-15	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-sed' -- cross-userland sed"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_UPERL_SRC=${PKG_SRC}
CUI_UPERL_TEMP=cui-uperl-${PKG_VER}

FUDGE_UPERL_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_UPERL_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_UPERL_EXTRACTED=${EXTTEMP}/${CUI_UPERL_TEMP}/Makefile.micro

.PHONY: cui-uperl-extracted
cui-uperl-extracted: ${CUI_UPERL_EXTRACTED}

${CUI_UPERL_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} perl-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_UPERL_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_UPERL_TEMP}
	mv ${EXTTEMP}/perl-${PKG_VER} ${EXTTEMP}/${CUI_UPERL_TEMP}


## ,-----
## |	package configure
## +-----

CUI_UPERL_CONFIGURED=${EXTTEMP}/${CUI_UPERL_TEMP}/GNUmakefile

.PHONY: cui-uperl-configured
cui-uperl-configured: cui-uperl-extracted ${CUI_UPERL_CONFIGURED}

${CUI_UPERL_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_UPERL_TEMP} || exit 1 ;\
		cp Makefile.micro GNUmakefile || exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_UPERL_BUILT=${EXTTEMP}/${CUI_UPERL_TEMP}/microperl

.PHONY: cui-uperl-built
cui-uperl-built: cui-uperl-configured ${CUI_UPERL_BUILT}

${CUI_UPERL_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_UPERL_TEMP} || exit 1 ;\
		make CC=${TC_ROOT}/usr/bin/${FUDGE_UPERL_TARGET_SPEC}-gcc \
			|| exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_UPERL_INSTALLED=${FUDGE_UPERL_INSTROOT}/usr/bin/microperl

.PHONY: cui-uperl-installed
cui-uperl-installed: cui-uperl-built ${CUI_UPERL_INSTALLED}

${CUI_UPERL_INSTALLED}:
	mkdir -p ${FUDGE_UPERL_INSTROOT}
	( cd ${EXTTEMP}/${CUI_UPERL_TEMP} || exit 1 ;\
		mkdir -p ${FUDGE_UPERL_INSTROOT}/usr/bin/ || exit 1 ;\
		mkdir -p ${FUDGE_UPERL_INSTROOT}/usr/lib/perl5/perl-5.9/ || exit 1 ;\
		cp -dpf microperl ${FUDGE_UPERL_INSTROOT}/usr/bin/microperl ;\
		cp -r lib/* ${FUDGE_UPERL_INSTROOT}/usr/lib/perl5/perl-5.9 || exit 1 \
	) || exit 1


.PHONY: all-CUI
all-CUI: cui-uperl-installed
