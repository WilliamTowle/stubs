#!/bin/sh

SITE=$1
if [ -z "$SITE" ] ; then
	echo "$0: No 'SITE' (or LIST) supplied"
	exit 1
else
	shift
	[ -r $SITE ] && SITE=`cat $SITE`
fi

LIST=$1
if [ -z "$LIST" ] ; then
	echo "$0: No 'LIST' supplied"
	exit 1
else
	shift
fi


dl_filemode()
{
	DLFILE=$1
	TARGET=$2
	[ -d `dirname $TARGET` ] || mkdir -p `dirname $TARGET`
	lynx -dump $DLFILE > $TARGET || exit 1
}

echo "$0: Downloading..."

PKGDIR=packages/rpm

for FILE in `grep -v '^#' $LIST` ; do
	ARCH=`basename ${FILE} | sed 's/\.rpm$//' | sed 's/.*\.//'`
	URL=${SITE}/${ARCH}/${FILE}
	TARGET=${PKGDIR}/${ARCH}/${FILE}
	echo -n "$FILE: "
	if [ -r $TARGET ] ; then
		echo "OK"
	else
		[ -d ${PKGDIR}/${ARCH} ] || mkdir -p ${PKGDIR}/${ARCH}
		dl_filemode ${URL} ${TARGET}
		echo "DONE"
	fi
done

echo "$0: OK"
