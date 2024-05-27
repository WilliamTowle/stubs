#!/bin/sh
# cutemouse v2.1b4
# Last modified WmT 2011-04-13
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos/utils/ctmouse || exit 1
#	cp bin/ctm-br.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-de.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
	cp bin/ctm-en.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-es.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-fr.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-hu.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-it.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-lv.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-nl.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-pl.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-pt.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctm-sk.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
	cp bin/com2exe.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
#	cp bin/ctmdebug.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
	cp bin/ctmouse.exe ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
	cp bin/mousetst.com ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
	cp bin/comtest.com ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
	cp bin/protocol.com ${INSTTEMP}/dos/utils/ctmouse/ || exit 1
}

##
##	main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
CUI)	## install to cross-userland
	do_build_cui $* || exit 1
;;
*)
	echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
	exit 1
;;
esac
