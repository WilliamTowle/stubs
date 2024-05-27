#!/bin/sh
# wills-game vUNKNOWN
# Last modified WmT 2011-07-22
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/wills || exit 1

	cp wills/bloktris.exe ${INSTTEMP}/wills/ || exit 1
	cp wills/bloktris.sco ${INSTTEMP}/wills/ || exit 1
	cp wills/chitiles.dat ${INSTTEMP}/wills/ || exit 1
	cp wills/chitiles.doc ${INSTTEMP}/wills/ || exit 1
	cp wills/chitiles.exe ${INSTTEMP}/wills/ || exit 1
	cp wills/chitiles.sco ${INSTTEMP}/wills/ || exit 1
	cp wills/chitimg.cga ${INSTTEMP}/wills/ || exit 1
	cp wills/invaders.exe ${INSTTEMP}/wills/ || exit 1
	cp wills/invaders.sco ${INSTTEMP}/wills/ || exit 1
	cp wills/mmind.exe ${INSTTEMP}/wills/ || exit 1
	cp wills/modulimg.cga ${INSTTEMP}/wills/ || exit 1
	cp wills/modulo-4.doc ${INSTTEMP}/wills/ || exit 1
	cp wills/modulo-4.exe ${INSTTEMP}/wills/ || exit 1
	cp wills/modulo-4.lev ${INSTTEMP}/wills/ || exit 1
	cp wills/modulo-4.sco ${INSTTEMP}/wills/ || exit 1
	cp wills/pcpiano.exe ${INSTTEMP}/wills/ || exit 1
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
