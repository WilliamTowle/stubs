# bzip2 v1.0.5			[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-bzip2' -- cross-userland bzip2"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_BZIP2_SRC=${PKG_SRC}
CUI_BZIP2_TEMP=cui-bzip2-${PKG_VER}

FUDGE_BZIP2_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_BZIP2_INSTROOT=${EXTTEMP}/insttemp


## ,-----
## |	package extract
## +-----

CUI_BZIP2_EXTRACTED=${EXTTEMP}/${CUI_BZIP2_TEMP}/Makefile

.PHONY: cui-bzip2-extracted
cui-bzip2-extracted: ${CUI_BZIP2_EXTRACTED}

${CUI_BZIP2_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} bzip2-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_BZIP2_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_BZIP2_TEMP}
	mv ${EXTTEMP}/bzip2-${PKG_VER} ${EXTTEMP}/${CUI_BZIP2_TEMP}


## ,-----
## |	package configure
## +-----

CUI_BZIP2_CONFIGURED=${EXTTEMP}/${CUI_BZIP2_TEMP}/Makefile.OLD

.PHONY: cui-bzip2-configured
cui-bzip2-configured: cui-bzip2-extracted ${CUI_BZIP2_CONFIGURED}

${CUI_BZIP2_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_BZIP2_TEMP} || exit 1 ;\
		find ./ -name "Makefile*" | while read MF ; do \
			[ -r $${MF}.OLD ] || mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed	' /^CC=/	s%g*cc%'${TC_ROOT}'/usr/bin/'${FUDGE_BZIP2_TARGET_SPEC}'-gcc%' \
				| sed	' /^AR=/	s%ar%'`echo ${TC_ROOT}'/usr/bin/'${FUDGE_BZIP2_TARGET_SPEC}'-gcc' | sed 's/gcc$$/ar/'`'%' \
				| sed	' /^RANLIB=/	s%ranlib%'`echo ${TC_ROOT}'/usr/bin/'${FUDGE_BZIP2_TARGET_SPEC}'-gcc' | sed 's/gcc$$/ranlib/'`'%' \
				| sed	' /^BIGFILES=/	s/^/#/' \
				| sed	' /^CFLAGS=/	s/ -g / /' \
				| sed	' /^PREFIX=/	s%=.*%= '${FUDGE_BZIP2_INSTROOT}'/usr%' \
				| sed	' /^all:/	s/test//' \
				> $${MF} || exit 1 ;\
		done \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_BZIP2_BUILT=${EXTTEMP}/${CUI_BZIP2_TEMP}/bzip2

.PHONY: cui-bzip2-built
cui-bzip2-built: cui-bzip2-configured ${CUI_BZIP2_BUILT}

${CUI_BZIP2_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_BZIP2_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_BZIP2_INSTALLED=${FUDGE_BZIP2_INSTROOT}/usr/bin/bzip2

.PHONY: cui-bzip2-installed
cui-bzip2-installed: cui-bzip2-built ${CUI_BZIP2_INSTALLED}

${CUI_BZIP2_INSTALLED}:
	mkdir -p ${FUDGE_BZIP2_INSTROOT}
	( cd ${EXTTEMP}/${CUI_BZIP2_TEMP} || exit 1 ;\
		mkdir -p ${FUDGE_BZIP2_INSTROOT} || exit 1 ;\
		make DESTDIR=${FUDGE_BZIP2_INSTROOT} install || exit 1 \
	) || exit 1
	( cd ${FUDGE_BZIP2_INSTROOT}/usr/bin || exit 1 ;\
		ln -sf bzdiff bzcmp || exit 1 ;\
		ln -sf bzmore bzless || exit 1 ;\
		ln -sf bzgrep bzegrep || exit 1 ;\
		ln -sf bzgrep bzfgrep || exit 1 \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-bzip2-extracted
#all-CUI: cui-bzip2-configured
#all-CUI: cui-bzip2-built
all-CUI: cui-bzip2-installed
