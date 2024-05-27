#!/bin/sh
# 03/04/2006

#MICROPERL_VER=5.8.7
#MICROPERL_SOURCE=perl-$(MICROPERL_VER).tar.bz2
#MICROPERL_SITE=ftp://ftp.cpan.org/pub/CPAN/src/5.0

#$(MICROPERL_DIR)/microperl: $(MICROPERL_DIR)/.source
#	$(MAKE) -f Makefile.micro CC=$(TARGET_CC) -C $(MICROPERL_DIR)
#
#$(TARGET_DIR)/usr/bin/microperl: $(MICROPERL_DIR)/microperl
#	cp -dpf $(MICROPERL_DIR)/microperl $(TARGET_DIR)/usr/bin/microperl
#
#microperl: uclibc $(TARGET_DIR)/usr/bin/microperl
#
#microperl-source: $(DL_DIR)/$(MICROPERL_SOURCE)
#
#microperl-clean:
#	rm -f $(TARGET_DIR)/usr/bin/microperl
#	-$(MAKE) -C $(MICROPERL_DIR) clean
#
#microperl-dirclean:
#	rm -rf $(MICROPERL_DIR)
#
##############################################################
##
## Toplevel Makefile options
##
##############################################################
#ifeq ($(strip $(BR2_PACKAGE_MICROPERL)),y)
#TARGETS+=microperl
#endif

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

	case ${PKGVER} in
	5.8.8)
	cat <<EOF > GNUmakefile
#!`which make`

CC=${FR_CROSS_CC}

.SUFFIXES:
.SUFFIXES: .c .o

.c.o: \$*.c \$*.h
	\${CC} \${CFLAGS} -c \$*.c -o \$@

EOF

	cat Makefile.micro >> GNUmakefile || exit 1
	;;
	*)	echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

##
#	# this bit for Makefile
#	[ ! -r config.sh ] || rm -f config.sh
#	[ ! -r Policy.sh ] || rm -f Policy.sh
#	sh Configure -de
###	--
#	[ -r config.sh.OLD ] || cp config.sh config.sh.OLD
#	cat config.sh.OLD \
#		| sed "s%usr/local%${FR_TH_ROOT}/usr%" \
#		> config.sh

# BUILD...
	make || exit 1
	#make LIBS=${ADD_LIBC_NCURSES} || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin/ || exit 1
	mkdir -p ${INSTTEMP}/usr/local/lib/perl5/perl-5.9/ || exit 1
	#mkdir -p ${INSTTEMP}/usr/share/doc/microperl-${PKGVER} || exit 1
	cp -dpf microperl ${INSTTEMP}/usr/local/bin/microperl

#	make -f Makefile bin=${FR_TH_ROOT}/usr/bin scriptdir=${FR_TH_ROOT}/usr/bin man1dir=${FR_TH_ROOT}/usr/man/man1 man3dir=${FR_TH_ROOT}/usr/man/man3 install
	cp -r lib/* ${INSTTEMP}/usr/local/lib/perl5/perl-5.9 || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
