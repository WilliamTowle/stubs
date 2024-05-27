#!/bin/sh
# find v30may2003
# Last modified WmT 2011-07-20
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/dos || exit 1
	cp bin/find.com ${INSTTEMP}/dos/find.com
	cp nls/find.en  ${INSTTEMP}/dos/find.en
#	cp nls/find.ru  ${INSTTEMP}/dos/find.ru
#	cp nls/find.lv  ${INSTTEMP}/dos/find.lv
#	cp nls/find.sv  ${INSTTEMP}/dos/find.sv
#	cp nls/find.de  ${INSTTEMP}/dos/find.de
#	cp nls/find.hu  ${INSTTEMP}/dos/find.hu
#	cp nls/find.it  ${INSTTEMP}/dos/find.it
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
