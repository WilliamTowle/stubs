#!/bin/sh

SITE=$1
if [ -z "$SITE" ] ; then
	echo "$0 expected SITE parameter"
	exit 1
fi

[ -r $SITE ] && SITE=`cat $SITE`

for SUBDIR in noarch mips ; do
	lynx -dump ${SITE}/${SUBDIR} | grep ':\/\/.*rpm' | while read SPEC ; do
		URL=` echo $SPEC | sed 's/.*\. //' | sed 's/rpm.*/rpm/' `
		echo $URL | sed 's/.*\///'
	done
done
