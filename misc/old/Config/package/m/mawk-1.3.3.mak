# mawk v1.3.3			[ since v1.3.3, c.????-??-?? ]
# last mod WmT, 2009-12-25	[ (c) and GPLv2 1999-2009 ]

#DESCRLIST+= "'nti-mawk' -- host-toolchain mawk"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak


## ,-----
## |	package extract
## +-----

NTI_MAWK_TEMP=nti-mawk-${PKG_VER}
NTI_MAWK_EXTRACTED=${EXTTEMP}/${NTI_MAWK_TEMP}/configure

.PHONY: nti-mawk-extracted
nti-mawk-extracted: ${NTI_MAWK_EXTRACTED}

${NTI_MAWK_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
	${SCRIPTBIN}/extract ${EXTTEMP} mawk-${PKG_VER} ${PKG_SRC}
	[ ! -r ${EXTTEMP}/${NTI_MAWK_TEMP} ] || rm -rf ${EXTTEMP}/${NTI_MAWK_TEMP}
	mv ${EXTTEMP}/mawk-${PKG_VER} ${EXTTEMP}/${NTI_MAWK_TEMP}


## ,-----
## |	package configure
## +-----

NTI_MAWK_CONFIGURED=${EXTTEMP}/${NTI_MAWK_TEMP}/Makefile.OLD

.PHONY: nti-mawk-configured
nti-mawk-configured: nti-mawk-extracted ${NTI_MAWK_CONFIGURED}

${NTI_MAWK_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${NTI_MAWK_TEMP} || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
	    	  MATHLIB=-lm \
			./configure \
			  || exit 1 ;\
		\
		for MF in ` find ./ -name Makefile ` ; do \
			mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed '/^BINDIR/ s%/usr.*bin%$${DESTDIR}/usr/bin%' \
				| sed '/^MANDIR/ s%/usr.*man1%$${DESTDIR}/usr/man/man1%' \
				| sed '/^	/ s%./mawktest%$${SHELL} ./mawktest%' \
				| sed '/^	/ s%./fpe_test%$${SHELL} ./fpe_test%' \
				| sed '/(MAWKMAN)/ s/	/	$${INSTMAN} /' \
				> $${MF} || exit 1 ;\
		done \
	)


## ,-----
## |	package build
## +-----

NTI_MAWK_BUILT=${EXTTEMP}/${NTI_MAWK_TEMP}/mawk

.PHONY: nti-mawk-built
nti-mawk-built: nti-mawk-configured ${NTI_MAWK_BUILT}

## 2008-10-14: Do not assume 'mawk_and_test' is functional. m4 circa
## v1.4.12 introduces circular dependencies between bash/m4/mawk/bison.
${NTI_MAWK_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${NTI_MAWK_TEMP} || exit 1 ;\
		make || exit 1 \
	)
##		make mawk || exit 1 \
##		make SHELL=${HTC_ROOT}/bin/bash mawk_and_test || exit 1


## ,-----
## |	package install
## +-----

NTI_MAWK_INSTALLED=${NTI_ROOT}/usr/bin/mawk

.PHONY: nti-mawk-installed
nti-mawk-installed: nti-mawk-built ${NTI_MAWK_INSTALLED}

${NTI_MAWK_INSTALLED}: ${NTI_ROOT}
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${NTI_MAWK_TEMP} || exit 1 ;\
		mkdir -p ${NTI_ROOT}/usr/bin || exit 1 ;\
		make DESTDIR=${NTI_ROOT} INSTMAN=-false install || exit 1 ;\
		( cd ${NTI_ROOT}/usr/bin && ln -sf mawk awk ) || exit 1 \
	)


.PHONY: all-NTI
all-NTI: nti-mawk-installed
