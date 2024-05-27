#!/bin/sh
# 15/03/2004

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/usr/local/bin || exit 1
	for SCRIPT in ff fl ; do
		cp ${SCRIPT} ${INSTTEMP}/usr/local/bin || exit 1
		chmod a+x ${INSTTEMP}/usr/local/bin/${SCRIPT} || exit 1
	done
}

#make_th()
#{
#}

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
