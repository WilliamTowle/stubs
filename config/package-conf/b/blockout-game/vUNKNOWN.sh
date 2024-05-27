#!/bin/sh
# blockout-game vUNKNOWN
# Last modified WmT 2011-07-22
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/blockout || exit 1

	cp blockout/blockout.set ${INSTTEMP}/blockout/ || exit 1
	cp blockout/bl.exe ${INSTTEMP}/blockout/ || exit 1
	cp blockout/bl2.ovl ${INSTTEMP}/blockout/ || exit 1
	cp blockout/fonts_h.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/fonts_l.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/fonts_m.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/graftabl.cga ${INSTTEMP}/blockout/ || exit 1
	cp blockout/logo_h.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/logo_l.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/logo_m.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/panel_h.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/panel_l.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/panel_m.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/title_h.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/title_l.lbm ${INSTTEMP}/blockout/ || exit 1
	cp blockout/title_m.lbm ${INSTTEMP}/blockout/ || exit 1
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
