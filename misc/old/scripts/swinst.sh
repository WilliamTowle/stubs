#!/bin/sh

do_install_swtgz()
{
	DIRTO=$1
	if [ ! -d ${DIRTO} ] ; then
		echo "$0: Missing DIRTO ${DIRTO}" 1>&2
		exit 1
	else
		shift
	fi

	ARCHIVE=$1
	if [ ! -s "${ARCHIVE}" ] ; then
		echo "$0: Missing or empty ARCHIVE ${ARCHIVE}" 1>&2
		exit 1
	else
		shift
	fi

	gzip -dc ${ARCHIVE} | tar xf - -C ${DIRTO}
}

#if [ "$UID" != '0' ] ; then
#	echo "$0: Not root" 1>&2
#	exit 1
#fi

if [ -z "$1" ] ; then
	echo "$0: No ROOTDIR" 1>&2
	exit 1
else
	ROOTDIR=$1
	shift
fi

if [ -z "$1" ] ; then
	echo "$0: No PKG[s]" 1>&2
	exit 1
fi

while [ "$1" ] ; do
	PKG=$1
	shift

	echo "Extracting ${PKG}..."
	do_install_swtgz ${ROOTDIR} ${PKG}
	if [ -r ${ROOTDIR}/install/doinst.sh ] ; then
		( cd ${ROOTDIR} && sh install/doinst.sh && rm -rf install )
	fi
done
