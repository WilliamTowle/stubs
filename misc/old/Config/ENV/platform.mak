## 'ifbuild' build/target-platform configuration
## lm 2010-06-02

ifneq (${HAVE_PLAT_CONFIG},y)
HAVE_PLAT_CONFIG:= y

## native system

NATIVE_GCC:= $(shell which gcc 2>/dev/null || echo '/usr/bin/gcc')

## host system

NATIVE_SPEC:= $(shell if [ -r /lib/ld-uClibc.so.0 ] ; then echo ${NATIVE_CPU}'-host-linux-uclibc' ; else echo ${NATIVE_CPU}'-host-linux-gnu' ; fi)

NTI_ROOT:= ${TOPLEV}/toolchain

## target system

TARGET_SPEC:=${TARGET_CPU}-homebrew-linux-uclibc

TARGET_MIN_SPEC:=${TARGET_CPU}-minimal-linux-uclibc

CTI_ROOT:= ${TOPLEV}/toolchain

##

ifeq ($(shell [ -r ${NTI_ROOT}/bin ] && echo y),y)
PATH:=${NTI_ROOT}/bin:${PATH}
endif
ifeq ($(shell [ -r ${NTI_ROOT}/usr/bin ] && echo y),y)
PATH:=${NTI_ROOT}/usr/bin:${PATH}
endif

endif	# HAVE_PLAT_CONFIG
