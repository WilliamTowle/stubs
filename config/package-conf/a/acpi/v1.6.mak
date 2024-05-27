#!/usr/bin/make
# acpi v1.6		   	STUBS (c) and GPLv2 1999-2015
# last modified			2015-01-26

include ./package.cfg
include ${TCTREE}/etc/buildcfg.mk

CUI_ACPI_SRCROOT	= ${BUILDROOT}/CUI-acpi-${PKGVER}/source/${PKGNAME}-${PKGVER}

CUI_ACPI_CONFIGURED=	${CUI_ACPI_SRCROOT}/config.log
CUI_ACPI_BUILT=		${CUI_ACPI_SRCROOT}/src/acpi
CUI_ACPI_INSTALLED=	${INSTTEMP}/usr/bin/acpi


## ,-----
## |	Configure
## +-----

${CUI_ACPI_CONFIGURED}:
	( cd ${CUI_ACPI_SRCROOT} || exit 1 ;\
		./configure --prefix=/usr \
			--build=${HOSTSPEC} \
			--host=${TARGSPEC} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Build
## +-----

${CUI_ACPI_BUILT}: ${CUI_ACPI_CONFIGURED}
	( cd ${CUI_ACPI_SRCROOT} || exit 1 ;\
		make \
	)
	[ "${VERIFY}" != 'y' ] || ls $@


## ,-----
## |	Install
## +-----

${CUI_ACPI_INSTALLED}: ${CUI_ACPI_BUILT}
	( cd ${CUI_ACPI_SRCROOT} || exit 1 ;\
		make install DESTDIR=${INSTTEMP} \
	)
	[ "${VERIFY}" != 'y' ] || ls $@

.PHONY: cui-acpi
cui-acpi: ${CUI_ACPI_INSTALLED}

.PHONY: CUI
CUI: ${CUI_ACPI_INSTALLED}
