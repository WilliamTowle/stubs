#!/bin/sh -x
# 2004-10-02

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

do_configure()
{
	[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1
	cat Makefile.OLD \
		| sed '/^CC[ 	]*/	s%=.*%= '${FR_CROSS_CC}'%' \
		| sed '/^LD[ 	]*/	s%=.*%= '${FR_CROSS_CC}'%' \
		| sed '/^#COMBINED_BINARY/ s/#//' \
		| sed 's%^SBINDIR=.*%SBINDIR=${prefix}/sbin%' \
		| sed 's%$(USRBINDIR)%${DESTDIR}/$(USRBINDIR)%' \
		| sed 's%$(USRSBINDIR)%${DESTDIR}/$(USRSBINDIR)%' \
		| sed 's%$(USRSHAREDIR)%${DESTDIR}/$(USRSHAREDIR)%' \
		| sed 's%$(SBINDIR)%${DESTDIR}/$(SBINDIR)%' \
		> Makefile || exit 1

	case ${PHASE}-${FR_TARGET_DEFN} in
	dc*uclibc*|dc*earlgrey*)
		for SF in socket.c packet.c ; do
			[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
			cat ${SF}.OLD \
				| sed '/__GLIBC__/ { s%if%if 1 /* uClibc 0.9.20 ... was % ; s%$% */% }' \
				> ${SF} || exit 1
		done
	;;
	esac
}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

	PHASE=dc do_configure || exit 1

# BUILD...
	make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin ${INSTTEMP}/usr/sbin || exit 1
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
