#!/bin/sh
# 07/12/2005

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

	cat >GNUmakefile <<EOF
#!/bin/make

CC=${FR_CROSS_CC}

# -nostdinc -I${UCPATH}/include -I${GCCINCDIR} -I${TCTREE}/usr/include \
default: all
diskimg:
	\${CC} \
		diskimg.c -o diskimg

install: diskimg
	mkdir -p \${DESTDIR}/usr/local/bin/
	cp diskimg \${DESTDIR}/usr/local/bin/

EOF
	cat Makefile >> GNUmakefile
	[ -r diskimg.c.OLD ] || mv diskimg.c diskimg.c.OLD || exit 1
	cat diskimg.c.OLD \
		| sed 's%O_LARGEFILE%0 /* O_LARGEFILE */%' \
		| sed 's/lseek64/lseek/' \
		| sed 's/off64_t/off_t/' \
		| sed 's/open64/open/' \
		> diskimg.c || exit 1

# BUILD...

#		make CCPREFIX=${TARGET_CPU}-uclibc-g || exit 1
	make || exit 1

# INSTALL...
	make DESTDIR=${INSTTEMP} install || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
#toolchain-host)
#	INSTTEMP=${TCTREE} make_th || exit 1
#	;;
*)
	exit 1
	;;
esac
