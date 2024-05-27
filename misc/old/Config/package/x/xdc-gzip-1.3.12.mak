# gzip v4.2.33			[ since v?.?, c.????-??-?? ]
# last mod WmT, 2010-03-11	[ (c) and GPLv2 1999-2010 ]

## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-gzip' -- cross-userland gzip"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CUI_GZIP_SRC=${PKG_SRC}
CUI_GZIP_TEMP=cui-gzip-${PKG_VER}

FUDGE_GZIP_TARGET_SPEC=${TARGET_CPU}-lungching-linux-uclibc
FUDGE_GZIP_INSTROOT=${EXTTEMP}/insttemp

## ,-----
## |	package extract
## +-----

CUI_GZIP_EXTRACTED=${EXTTEMP}/${CUI_GZIP_TEMP}/Makefile

.PHONY: cui-gzip-extracted
cui-gzip-extracted: ${CUI_GZIP_EXTRACTED}

${CUI_GZIP_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} gzip-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${CUI_GZIP_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_GZIP_TEMP}
	mv ${EXTTEMP}/gzip-${PKG_VER} ${EXTTEMP}/${CUI_GZIP_TEMP}


## ,-----
## |	package configure
## +-----

CUI_GZIP_CONFIGURED=${EXTTEMP}/${CUI_GZIP_TEMP}/config.status

.PHONY: cui-gzip-configured
cui-gzip-configured: cui-gzip-extracted ${CUI_GZIP_CONFIGURED}

${CUI_GZIP_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_GZIP_TEMP} || exit 1 ;\
		CC=${TC_ROOT}/usr/bin/${FUDGE_GZIP_TARGET_SPEC}-gcc \
		  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | gzip 's/-gnulibc1//') \
			  --build=${FUDGE_GZIP_TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			|| exit 1 \
	)	|| exit 1


## ,-----
## |	package build
## +-----

CUI_GZIP_BUILT=${EXTTEMP}/${CUI_GZIP_TEMP}/gzip

.PHONY: cui-gzip-built
cui-gzip-built: cui-gzip-configured ${CUI_GZIP_BUILT}

${CUI_GZIP_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_GZIP_TEMP} || exit 1 ;\
		make || exit 1 \
	) || exit 1


## ,-----
## |	package install
## +-----


CUI_GZIP_INSTALLED=${FUDGE_GZIP_INSTROOT}/usr/bin/gzip

.PHONY: cui-gzip-installed
cui-gzip-installed: cui-gzip-built ${CUI_GZIP_INSTALLED}

${CUI_GZIP_INSTALLED}:
	for SD in usr/bin usr/bin usr/info usr/man/man1 ; do \
		mkdir -p ${FUDGE_GZIP_INSTROOT}/usr/bin ;\
	done
	( cd ${EXTTEMP}/${CUI_GZIP_TEMP} || exit 1 ;\
		make DESTDIR=${FUDGE_GZIP_INSTROOT} install-exec-recursive || exit 1 \
	) || exit 1
	( cd ${FUDGE_GZIP_INSTROOT} || exit 1 ;\
		for F in usr/bin/gunzip usr/bin/gzexe \
			usr/bin/uncompress usr/bin/zcat usr/bin/zcmp \
			usr/bin/zdiff usr/bin/zegrep usr/bin/zfgrep \
			usr/bin/zforce usr/bin/zgrep usr/bin/zless \
			usr/bin/zmore usr/bin/znew ; do \
			mv $${F} ${EXTTEMP}/${CUI_GZIP_TEMP}/`basename $$F`.orig || exit 1 ;\
			sed 's%'${TC_ROOT}'%% ; T a ; s%/bin/bash%/bin/sh% ; :a' ${EXTTEMP}/${CUI_GZIP_TEMP}/`basename $$F`.orig > $${F} ;\
			chmod a+x $${F} || exit 1 ;\
		done \
	) || exit 1


.PHONY: all-CUI
#all-CUI: cui-gzip-extracted
#all-CUI: cui-gzip-configured
#all-CUI: cui-gzip-built
all-CUI: cui-gzip-installed
