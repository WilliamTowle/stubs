#!/bin/sh

## instmgr.sh		(c)1999-2007 William Towle
## Last modified	20/03/2007, WmT
## Purpose		Generate database of installed programs
#
#   Open Source software - copyright and GPLv2 apply. Briefly:
#	- No warranty/guarantee of fitness, use is at own risk
#	- No restrictions on strictly-private use/copying/modification
#	- No re-licensing this work under more restrictive terms
#	- Redistributing? Include/offer to deliver original source
#   Philosophy/full details at http://www.gnu.org/copyleft/gpl.html

[ "${DBROOT}" ] || DBROOT=/
DBDIR=${DBROOT}/opt/freglx/etc
[ "${DBFILE}" ] || DBFILE=pkgver.dat
[ "${TMPDIR}" ] || TMPDIR=/tmp/

do_init()
{
	mkdir -p ${DBDIR} || exit 1
	echo -n '' > ${DBDIR}/${DBFILE} || exit 1
}

get_value()
{
	FILE=$1
	TERM=$2

	grep "^${TERM}" ${FILE}
}

set_value()
{
	FILE=$1
	TERM=$2
	VALUE=$3

	cp ${FILE} ${TMPDIR}/tmp.$$ || exit 1
	( grep -v "^${TERM}	" ${TMPDIR}/tmp.$$ ; echo "${TERM}	${VALUE}" ) > ${FILE} || exit 1
	rm ${TMPDIR}/tmp.$$
}

db_query()
{
	if [ ! -r ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBDIR ${DBDIR} and/or DBFILE ${DBFILE} not present" 1>&2
		exit 1
	fi

	if [ ! -s ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBFILE ${DBDIR}/${DBFILE} empty" 1>&2
		exit 1
	fi

	if [ -z "$1" ] ; then
		cat ${DBDIR}/${DBFILE}
	else
		while [ "$1" ] ; do
			get_value ${DBDIR}/${DBFILE} $1
			shift
		done
	fi
}

db_depchk()
{
	if [ ! -r ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBDIR ${DBDIR} and/or DBFILE ${DBFILE} not present" 1>&2
		exit 1
	fi

	if [ ! -s ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBFILE ${DBDIR}/${DBFILE} empty" 1>&2
		exit 1
	fi

	if [ -z "$1" ] ; then
		echo "db_depchk(): PACKAGE [optional 'test' args] expected" 1>&2
		exit 1
	fi

	PKGNAME=$1
	shift
	VERNOW=`get_value ${DBDIR}/${DBFILE} ${PKGNAME} 2>/dev/null`
	if [ -z "${VERNOW}" ] ; then
		echo "${PKGNAME} not installed" 1>&2
		exit 1
	fi

	# FUTURE: is 'test' suitable? eg. can't do 4.1.5 -gt 4.1.6
#	if [ "$1" ] ; then
#		[ ${VERNOW} $* ] || exit 1
#	fi
}

db_enlist()
{
	if [ ! -r ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBDIR ${DBDIR} and/or DBFILE ${DBFILE} not present" 1>&2
		exit 1
	fi

	if [ -z "$1" ] ; then
		echo "$0: Expected PKGNAME (and PKGVER)" 2>&1
		exit 1
	else
		PKGNAME=$1
		shift
	fi
	if [ -z "$1" ] ; then
		echo "$0: Expected PKGVER" 2>&1
		exit 1
	else
		PKGVER=$1
		shift
	fi

	VERNOW=`get_value ${DBDIR}/${DBFILE} ${PKGNAME} 2>/dev/null`
	if [ -z "${VERNOW}" ] ; then
		set_value ${DBDIR}/${DBFILE} ${PKGNAME} ${PKGVER} || exit 1
	else
		echo "$0: Installed: ${VERNOW}"
		exit 1
	fi
}

db_upgrade()
{
	if [ ! -r ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBDIR ${DBDIR} and/or DBFILE ${DBFILE} not present" 1>&2
		exit 1
	fi

	if [ -z "$1" ] ; then
		echo "$0: Expected PKGNAME (and PKGVER)" 2>&1
		exit 1
	else
		PKGNAME=$1
		shift
	fi
	if [ -z "$1" ] ; then
		echo "$0: Expected PKGVER" 2>&1
		exit 1
	else
		PKGVER=$1
		shift
	fi

	# TODO: check greater value?
	set_value ${DBDIR}/${DBFILE} ${PKGNAME} ${PKGVER} || exit 1
}

db_unlist()
{
	if [ ! -r ${DBDIR}/${DBFILE} ] ; then
		echo "$0: DBDIR ${DBDIR} and/or DBFILE ${DBFILE} not present" 1>&2
		exit 1
	fi

	if [ -z "$1" ] ; then
		echo "$0: Expected PKGNAME" 2>&1
		exit 1
	else
		PKGNAME=$1
		shift
	fi


	grep -v "^${PKGNAME}	" ${DBDIR}/${DBFILE} > ${TMPDIR}/tmp.$$
	[ -r ${TMPDIR}/tmp.$$ ] || exit 1
	mv ${TMPDIR}/tmp.$$ ${DBDIR}/${DBFILE}
}


COMMAND=$1
[ "$1" ] && shift
case ${COMMAND} in
init)	## initialise database
	do_init && echo "OK"
;;
query)	## query PKGNAME
	db_query $*
;;
depchk)	## check PKGNAME dependency [optional 'test' args]
	db_depchk $*
;;
enlist)	## add PKGNAME, PKGVER - if not installed
	db_enlist $*
;;
upgrade) ## add PKGNAME, PKGVER - if installed
	db_upgrade $*
;;
erase)	## remove PKGNAME entry
	db_unlist $*
;;
*)
	if [ -n "${COMMAND}" -a "${COMMAND}" != 'help' ] ; then
		echo "$0: Unrecognised command '${COMMAND}'"
	fi
	echo "$0: Usage:"
	grep "^[0-9a-z]*)" $0 | sed "s/^/	/"
	exit 1
;;
esac
