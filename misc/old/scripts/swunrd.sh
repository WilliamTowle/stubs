#!/bin/sh

if [ "${UID}" != '0' -a "${UID}#${USER}" != '#root' ] ; then
	echo "$0: Not root" 1>&2
	exit 1
fi

if [ /bin/busybox -ef /bin/mount -a ! -r /proc/filesystems ] ; then
	echo "No /proc/filesystems, breaks busybox 'mount -t auto'" 1>&2
	exit 1
elif [ ! -r /sbin/losetup ] ; then
	echo "No /sbin/losetup, breaks device detection" 1>&2
	exit 1
fi

if [ -z "$1" ] ; then
	echo "$0: No INITRD archive" 1>&2
	exit 1
else
	INITRDGZ=$1
	shift
fi

if [ -z "$1" ] ; then
	echo "$0: No EXTDIR" 1>&2
	exit 1
else
	EXTDIR=$1
	shift
fi

[ "${TMPDIR}" ] || TMPDIR=./tmp
[ "${MNTTMP}" ] || MNTTMP=${TMPDIR}/mnt.$$
mkdir -p ${EXTDIR} ${MNTTMP}

OK=y
(
	echo "$0: Uncompressing INITRDGZ ${INITRDGZ}..."
	RDUNGZ=${TMPDIR}/rdungz.$$
	gzip -dc ${INITRDGZ} > ${RDUNGZ}
	if [ ! -s ${RDUNGZ} ] ; then
		echo "$0: FATAL - aborting" 1>&2
		exit 1
	fi

	echo "$0: Detecting loop devices..."
	LOOPDEV=`/sbin/losetup -f`
	if [ -z "${LOOPDEV}" ] ; then
		# TODO: Need busybox
		echo "$0: Cannot determine free loop device, aborting" 1>&2
		exit 1
	fi
	/sbin/losetup ${LOOPDEV} ${RDUNGZ} || exit 1

	echo "$0: Mount and copy (via ${LOOPDEV})..."
	mount -t auto ${LOOPDEV} ${MNTTMP} || exit 1
	( cd ${MNTTMP} && tar cvf - . ) | ( cd ${EXTDIR} && tar xvf - )

	# EeePC won't umount the device :(
	umount ${MNTTMP}
	losetup -d ${LOOPDEV}
	rm -f ${RDUNGZ}
) || OK=n

rmdir ${MNTTMP} ${TMPDIR}
if [ "${OK}" = 'n' ] ; then
	echo "$0: Failed" 1>&2
	exit 1
else
	exit 0
fi
