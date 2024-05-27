#!/bin/sh
# 18/06/2005

#TODO:- Cross compilation still "highly experimental" (v5.8.6)
#TODO:- Cross compilation requires "ssh"(!!!)
#TODO:- See Cross/README?

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

#	if [ ! -r ${FR_TH_ROOT}/usr/bin/fakeroot ] ; then
#		echo "$0: Aborting -- no 'fakeroot'" 1>&2
#		exit 1
#	fi

	[ ! -r config.sh ] || rm -f config.sh
	[ ! -r Policy.sh ] || rm -f Policy.sh

# FR_CCFLAGS='-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include -O2'

	#sh Configure -desK || exit 1
# -Dldflags=${FR_LDFLAGS} \
# -Dcc=${FR_CROSS_CC} -Dccflags="${FR_CCFLAGS}" \
#	PATH=${FR_LIBCDIR}/bin:${PATH}
#	    ${FR_TH_ROOT}/usr/bin/fakeroot \
#		sh Configure -de -Dprefix=/usr \
#		  -Dusecrosscompile \
#		  -Dtargetarch=${TARGET_ARCH}-linux \
#		  -Dtargethost=localhost \
#		  -Dcc=${FR_CROSS_CC} \
#		  -Duseinc=${FR_LIBCDIR}/include \
#		  -Dincpth=${FR_LIBCDIR}/include \
#		  -Dlibpth=${FR_LIBCDIR}/lib \
#		  -Dtestldflags='' \
#		  -Dusenm=false \
#		  -Duselargefiles=undef \
#		  || exit 1
		sh Configure -de -Dprefix=/usr \
		  -Dusecrosscompile \
		  -Dtargetarch=${TARGET_ARCH}-linux \
		  -Dtargethost=localhost \
		  -Dcc=${FR_CROSS_CC} \
		  -Duseinc=${FR_LIBCDIR}/include \
		  -Dincpth=${FR_LIBCDIR}/include \
		  -Dlibpth=${FR_LIBCDIR}/lib \
		  -Dtestldflags='' \
		  -Dusenm=false \
		  -Duselargefiles=undef \
		  || exit 1

	[ -r config.sh.OLD ] || cp config.sh config.sh.OLD
	cat config.sh.OLD \
		| sed "s^usr/local^${INSTTEMP}/usr/local^" \
		> config.sh || exit 1

# BUILD...
	# Uses cross compiler here (?!). No CC= HOSTCC= HOSTCCCMD=
	make CCCMD=${FR_HOST_CC} miniperl || exit 1

echo "..." ; exit 1

#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

	# expect `make test` to file due to cross compilation...
	make test || exit 1

# INSTALL...
#	make bin=${INSTTEMP}/usr/bin scriptdir=${INSTTEMP}/usr/bin \
#		man1dir=${INSTTEMP}/usr/man/man1 \
#		man3dir=${INSTTEMP}/usr/man/man3 \
#		install || exit 1
	make install || exit 1
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
