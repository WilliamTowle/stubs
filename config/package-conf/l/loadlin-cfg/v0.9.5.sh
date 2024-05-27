#!/bin/sh
# loadlin-cfg v0.9.5
# Last modified WmT 2011-07-20
# STUBS scripts and configurations (c) and GPLv2 Wm. Towle 1999-2011

#	. package.cfg

handle_make_bat()
{
	CONF=$1
	PARMS=$2

echo <<EOF_BAT
REM PATH/cd \franki\loadlin
loadlin.exe @${CONF} ${PARMS}
EOF_BAT
}

handle_make_cfg()
{
	KERN=$1

echo <<EOF_CFG
${KERN}

#root=/dev/hda1 rw
#ramdisk=0,no
#initrd=initrd.mnz ramdisk_size=1536

# kernel parameters
debug
no387
#               vga=ask,vga=extended
vga=normal

# confused ide0 interface?
#ide0=noprobe ide0=0x1f0,0x3f6,14

#[ZIP]          #aha152x=0x140,10,7,1
#[ZIP]          #max_scsi_luns=1
#ether=10,0x280,0xc8000,0xcbfff,eth0
#sound=0x0TTPPPID
EOF_CFG
}

do_build_cui()
{
# CONFIGURE...
#	cd source || exit 1

# BUILD...

# INSTALL...
	mkdir -p ${INSTTEMP}/franki/loadlin || exit 1

# franki/earlgrey 0.8.0/0.9.5
	handle_make_cfg 'vm2040.lx' \
		> ${INSTTEMP}/franki/loadlin/freg2040.cfg || exit 1

	handle_make_bat 'freg2040.cfg' \
		'initrd=freg080.mnz ramdisk_size=1536 root=/dev/ram' \
		> ${INSTTEMP}/franki/loadlin/2040080.bat || exit 1

	handle_make_bat 'freg2040.cfg' \
		'initrd=freg095.mnz ramdisk_size=1536 root=/dev/ram' \
		> ${INSTTEMP}/franki/loadlin/2040095.bat || exit 1

	handle_make_bat 'freg2040.cfg' \
		'ramdisk=0,no boot=/dev/hda1 root=/dev/hda1 rw' \
		> ${INSTTEMP}/franki/loadlin/2040hda1.bat || exit 1

# slackware
	handle_make_cfg 'slak2037.lx' \
		> ${INSTTEMP}/franki/loadlin/slak2037.cfg || exit 1

	handle_make_bat 'slak2037.cfg' \
		'initrd=umsdos.gz root=/dev/ram' \
		> ${INSTTEMP}/franki/loadlin/slakums.bat || exit 1

	handle_make_bat 'slak2037.cfg' \
		'ramdisk=0,no boot=/dev/hda3 root=/dev/hda3 rw' \
		> ${INSTTEMP}/franki/loadlin/slakhda3.bat || exit 1
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
