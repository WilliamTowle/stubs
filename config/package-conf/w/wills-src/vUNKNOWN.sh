#!/bin/sh
# wills-src vUNKNOWN
# Last modified WmT 2011-07-22
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

do_build_cui()
{
# CONFIGURE...
	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/wills/source || exit 1

	cp wills/source/ekvl-dev.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/ekvl1_53.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/tp6src.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/ashc-tmp.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/ashc011.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/ashc012.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/ashcro~1.gz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/jivm-bak.tgz ${INSTTEMP}/wills//source/ || exit 1
	cp wills/source/jivm.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/mimdis.tgz ${INSTTEMP}/wills/source/ || exit 1
	cp wills/source/bladj1~1.tgz ${INSTTEMP}/wills/source/ || exit 1
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
