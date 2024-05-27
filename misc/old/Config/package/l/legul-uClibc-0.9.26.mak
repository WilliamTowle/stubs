# xui-uClibc v0.9.26		[ since v0.9.15, c.2002-10-14 ]
# last mod WmT, 2010-05-25	[ (c) and GPLv2 1999-2010 ]


## ,-----
## |	package settings
## +-----

#DESCRLIST+= "'cui-xui-uClibc' -- userland toolchain uClibc"

include ${TOPLEV}/Config/ENV/ifbuild.env
include ${TOPLEV}/Config/ENV/platform.mak

CTI_LEGTC_UCLIBC_TARGET_MIN_SPEC:=$(shell echo ${TARGET_MIN_SPEC} | sed 's/uclibc$$/gnu/')


## ,-----
## |	package extract
## +-----

CUI_XUI_UCLIBC_TEMP=cui-xui-uClibc-${PKG_VER}
CUI_XUI_UCLIBC_EXTRACTED=${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP}/Makefile

FUDGE_UCLIBC_INSTROOT=${EXTTEMP}/insttemp

.PHONY: cui-xui-uClibc-extracted
cui-xui-uClibc-extracted: ${CUI_XUI_UCLIBC_EXTRACTED}

${CUI_XUI_UCLIBC_EXTRACTED}:
	echo "*** $@ (EXTRACTED) ***"
ifeq (${PKG_PATCHES},)
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC}
else
	${SCRIPTBIN}/extract ${EXTTEMP} uClibc-${PKG_VER} ${PKG_SRC} ${PKG_PATCHES}
	echo "*** ${PKG_NAME}: PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc/*patch ; do \
			patch --batch -d xui-uClibc-${PKG_VER} -Np1 < $${PF} ;\
			rm -f ${PF} ;\
		done \
	)
endif
	[ ! -r ${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP} ] || rm -rf ${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP}
	mv ${EXTTEMP}/uClibc-${PKG_VER} ${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP}


## ,-----
## |	package configure
## +-----

CUI_XUI_UCLIBC_CONFIGURED=${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP}/.config

.PHONY: cui-xui-uClibc-configured
cui-xui-uClibc-configured: cui-xui-uClibc-extracted ${CUI_XUI_UCLIBC_CONFIGURED}

${CUI_XUI_UCLIBC_CONFIGURED}:
	echo "*** $@ (CONFIGURED) ***"
	( cd ${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP} || exit 1 ;\
		cp ${CTI_ROOT}/etc/config-uClibc-${PKG_VER} .config || exit 1 ;\
		case ${PKG_VER} in \
		0.9.26) \
			[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1 ;\
			cat Rules.mak.OLD \
				| sed	' /^CROSS/	s%=.*%= '${CTI_ROOT}'/usr/bin/'${CTI_LEGTC_UCLIBC_TARGET_MIN_SPEC}'-% ; /(CROSS)/	s%$$(CROSS)%$$(shell if [ -n "$${CROSS}" ] ; then echo $${CROSS} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /USE_CACHE/ s/#// ; /usr.bin.*awk/ s%/usr/bin/awk%'${AWK_EXE}'% ' > Rules.mak || exit 1 \
		;; \
		*)	echo "$0: do_configure 'Makefile's: Unexpected PKG_VER ${PKG_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac ;\
		yes '' | make oldconfig || exit 1 \
	)


## ,-----
## |	package build
## +-----

CUI_XUI_UCLIBC_BUILT=${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP}/lib/libm.a

.PHONY: cui-xui-uClibc-built
cui-xui-uClibc-built: cui-xui-uClibc-configured ${CUI_XUI_UCLIBC_BUILT}

# full 'make' because we have libc, headers natively
${CUI_XUI_UCLIBC_BUILT}:
	echo "*** $@ (BUILT) ***"
	( cd ${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP} || exit 1 ;\
		make VERBOSE=y || exit 1 \
	)
#		0.9.28*) \
#			${MAKE} -C utils ldd.host \


## ,-----
## |	package install
## +-----

# TODO: handle 'ldd'? How?

CUI_XUI_UCLIBC_INSTALLED=${FUDGE_UCLIBC_INSTROOT}/lib/ld-uClibc.so.0

.PHONY: cui-xui-uClibc-installed
cui-xui-uClibc-installed: cui-xui-uClibc-built ${CUI_XUI_UCLIBC_INSTALLED}

${CUI_XUI_UCLIBC_INSTALLED}:
	echo "*** $@ (INSTALLED) ***"
	( cd ${EXTTEMP}/${CUI_XUI_UCLIBC_TEMP} || exit 1 ;\
		make PREFIX=${FUDGE_UCLIBC_INSTROOT}'/' install_runtime || exit 1 \
	)


.PHONY: all-CUI
all-CUI: cui-xui-uClibc-installed
