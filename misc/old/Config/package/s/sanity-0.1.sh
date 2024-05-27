#!/bin/sh
# sanity v0.1			[ since v0.1, c.2010-06-03 ]
# last mod WmT, 2010-06-03	[ (c) and GPLv2 1999-2010 ]

. ${TOPLEV}/Config/ENV/ifbuild.env || exit 1

do_test_all()
{
	echo 'Testing general install/configuration OK'
	echo '...TODO -- assumed OK (but see elsewhere [messy?]) :/' 1>&2
}

##

do_test_nui()
{
	do_test_all || exit 1
	echo 'Testing NUI environment (tftpdev native.mak) OK'
	echo '...TODO -- assumed OK; is it? :/' 1>&2
}

do_test_nti()
{
	do_test_all || exit 1
	echo 'Testing NTI environment (tftpdev native.mak) OK'
	echo '...TODO -- assumed OK; is it? :/' 1>&2
}

do_test_cti()
{
	do_test_all || exit 1
	echo 'Testing CTI environment (tftpdev target.mak) OK'
	echo '...TODO -- assumed OK; is it? :/' 1>&2
}

do_test_cui()
{
	do_test_all || exit 1
	echo 'Testing CUI environment (tftpdev target.mak) OK'
	echo '...TODO -- assumed OK; is it? :/' 1>&2
}


##
##      main program
##

BUILDTYPE=$1
[ "$1" ] && shift
case ${BUILDTYPE} in
NTI)	do_test_nti || exit 1
;;
NUI)	do_test_nui || exit 1
;;
CTI)	do_test_cti || exit 1
;;
CUI)	do_test_cui || exit 1
;;
*)
        echo "$0: Unexpected BUILDTYPE '${BUILDTYPE}'" 1>&2
        exit 1
;;
esac || exit 1
