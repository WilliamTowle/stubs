#!/usr/bin/make
# mawk v1.3.4			STUBS (c) and GPLv2 1999-2014
# last modified			2014-05-02

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

NTI_MAWK_SRCROOT	= ${BUILDROOT}/NTI-mawk-${PKGVER}/source/${PKGNAME}-${PKGVER}
CUI_MAWK_SRCROOT	= ${BUILDROOT}/CUI-mawk-${PKGVER}/source/${PKGNAME}-${PKGVER}

NTI_MAWK_CONFIGURED=	${NTI_MAWK_SRCROOT}/Makefile.OLD
NTI_MAWK_BUILT=		${NTI_MAWK_SRCROOT}/mawk
NTI_MAWK_INSTALLED=	${TCTREE}/usr/bin/mawk

CUI_MAWK_CONFIGURED=	${CUI_MAWK_SRCROOT}/Makefile.OLD
CUI_MAWK_BUILT=		${CUI_MAWK_SRCROOT}/mawk
CUI_MAWK_INSTALLED=	${INSTTEMP}/usr/bin/mawk


## ,-----
## |	Configure
## +-----

# This 'Makefile' reconfiguration for 1.3.4-YYYYMMDD versions
# TODO: can pass CC/CFLAGS to 'configure'
# TODO: 1.3.x needs different 'Makefile' tweaks
${NTI_MAWK_CONFIGURED}:
	( cd ${NTI_MAWK_SRCROOT} || exit 1 ;\
		./configure || exit 1 ;\
		for MF in ` find ./ -name Makefile ` ; do \
			mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed '/^prefix/	s%/local%%' \
				| sed 's%mkdirs.sh%./mkdirs.sh%' \
				> $${MF} || exit 1 ;\
		done \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_MAWK_CONFIGURED}:
	( cd ${CUI_MAWK_SRCROOT} || exit 1 ;\
		echo '*** UNTESTED ***' ; exit 1 ;\
		./configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} \
			--disable-largefile --disable-nls ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed 's%$${prefix}%$${DESTDIR}/$${prefix}%' \
			> Makefile || exit 1 \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${NTI_MAWK_BUILT}: ${NTI_MAWK_CONFIGURED}
	( cd ${NTI_MAWK_SRCROOT} || exit 1 ;\
		make mawk \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

${CUI_MAWK_BUILT}: ${CUI_MAWK_CONFIGURED}
	( cd ${CUI_MAWK_SRCROOT} || exit 1 ;\
		echo '*** UNTESTED ***' ; exit 1 ;\
		make mawk \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${NTI_MAWK_INSTALLED}: ${NTI_MAWK_BUILT}
	( cd ${NTI_MAWK_SRCROOT} || exit 1 ;\
		mkdir -p ${TCTREE}/usr/bin || exit 1 ;\
		make DESTDIR=${TCTREE} INSTMAN=-false install || exit 1 ;\
		( cd ${TCTREE}/usr/bin && ln -sf mawk awk ) || exit 1 \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: nti-mawk
nti-mawk: ${NTI_MAWK_INSTALLED}

.PHONY: NTI
NTI: ${NTI_MAWK_INSTALLED}


${CUI_MAWK_INSTALLED}: ${CUI_MAWK_BUILT}
	( cd ${CUI_MAWK_SRCROOT} || exit 1 ;\
		echo '*** UNTESTED ***' ; exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-mawk
cui-mawk: ${CUI_MAWK_INSTALLED}

.PHONY: CUI
CUI: ${CUI_MAWK_INSTALLED}
