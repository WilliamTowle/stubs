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
BOGUS_DC		echo "$0: CONFIGURE: Configuration not determined" 1>&2
	fi

# | sed 's%^gcc%'${TARGET_CPU}'-uclibc-gcc -nostdinc -I'${UCPATH}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	[ -r build.OLD ] || mv build build.OLD || exit 1
	cat build.OLD \
		| sed '/^gcc / s/$/|| exit 1/' \
		| sed '/^as / s/$/|| exit 1/' \
		| sed 's%^gcc%'${FR_CROSS_CC}'%' \
		> build || exit 1
	chmod a+x build || exit 1

	[ -r install.OLD ] || mv install install.OLD || exit 1
	cat install.OLD \
		| sed '/^mkdir / s/$/|| exit 1/' \
		| sed '/^cp / s/$/|| exit 1/' \
		| sed 's%/usr%${DESTDIR}/usr%' \
		> install || exit 1
	chmod a+x install || exit 1

# BUILD...

		sh -x ./build || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/bin || exit 1
	mkdir -p ${INSTTEMP}/usr/share/scc || exit 1
	[ -r ${INSTTEMP}/usr/share/scc/lib ] \
		&& rm -rf ${INSTTEMP}/usr/share/scc/lib
	DESTDIR=${INSTTEMP} ./install || exit 1
	[ -r ${INSTTEMP}/usr/share/scc/examples ] \
		&& rm -rf ${INSTTEMP}/usr/share/scc/examples
	cp -r test ${INSTTEMP}/usr/share/scc/examples || exit 1
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
