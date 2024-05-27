#!/bin/sh
# find v3.0a
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
	cp find-3.0/bin/find.com ${INSTTEMP}/dos/find.com
	cp find-3.0/nls/find.en  ${INSTTEMP}/dos/find.en
#	cp find-3.0/nls/find.ru  ${INSTTEMP}/dos/find.ru
#	cp find-3.0/nls/find.lv  ${INSTTEMP}/dos/find.lv
#	cp find-3.0/nls/find.sv  ${INSTTEMP}/dos/find.sv
#	cp find-3.0/nls/find.de  ${INSTTEMP}/dos/find.de
#	cp find-3.0/nls/find.hu  ${INSTTEMP}/dos/find.hu
#	cp find-3.0/nls/find.it  ${INSTTEMP}/dos/find.it
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
