#!/bin/sh
# 19/04/2005

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/host-utils/bin/gcc ] ; then
		FR_HOST_CC=${TCTREE}/host-utils/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi
	FR_CROSS_CXX=`echo ${FR_CROSS_CC} | sed 's/cc$/++/'`
	FR_HOST_CXX=`echo ${FR_HOST_CC} | sed 's/cc$/++/'`

#	[ -r test-groff.OLD ] || cp test-groff test-groff.OLD
#	echo "#!/bin/sh" > test-groff || exit 1
#	echo "exit 0" >> test-groff
#	cat test-groff.OLD | sed 's/^/#/' >> test-groff

#	PATH=${FR_LIBCDIR}/bin:${PATH}
	 CC=${FR_CROSS_CC} \
	 CCC=${FR_CROSS_CXX} \
		./configure --prefix=/usr \
		  --host=`uname -m` --build=${FR_TARGET_DEFN} \
		  --disable-largefile --disable-nls \
		  || exit 1

# | sed '/^CC=/ s%$% -nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
	# (22/06/2004) beware doing '--nostdinc' for g++ - the
	# libraries have their own "error.h"
	for MF in `find ./ -name Makefile` ; do
		[ -r ${MF}.OLD ] || mv ${MF} ${MF}.OLD || exit 1
		cat ${MF}.OLD \
			| sed '/^C*FLAGS/ s/-g //' \
			| sed '/^prefix/ s%/usr%${DESTDIR}/usr%' \
			| sed 's%groff/groff%groff/groff.host%' \
			> ${MF} || exit 1
	done

# BUILD...
	make CC=${FR_HOST_CC} CCC=${FR_HOST_CXX} || exit 1
	mv src/roff/groff/groff src/roff/groff/groff.host || exit 1

	rm -rf `find ./ -name "*.[oa]"`
#	PATH=${FR_LIBCDIR}/bin:${PATH}
		make || exit 1

# INSTALL...
	mkdir -p ${INSTTEMP}/usr
	make DESTDIR=${INSTTEMP} install || exit 1
}

make_th()
{
# CONFIGURE...
	if [ -r ${TCTREE}/host-utils/bin/gcc ] ; then
		FR_HOST_CC=${TCTREE}/host-utils/bin/gcc
	else
		FR_HOST_CC=`which gcc`
	fi
	if [ -d ${TCTREE}/cross-utils ] ; then
		FR_TC_ROOT=${TCTREE}/cross-utils
		FR_TH_ROOT=${TCTREE}/host-utils
	else
		FR_TC_ROOT=${TCTREE}/
		FR_TH_ROOT=${TCTREE}/
	fi
	FR_HOST_CXX=`echo ${FR_HOST_CC} | sed 's/cc$/++/'`

	CC=${FR_HOST_CC} \
	CCC=${FR_HOST_CXX} \
		./configure \
		  --prefix=${FR_TH_ROOT}/usr \
		  --host=`uname -m` --build=`uname -m` \
		  --disable-largefile --disable-nls \
		  || exit 1

# BUILD...
	make all || exit 1

# INSTALL...
	mkdir -p ${FR_TH_ROOT}/usr
	make install_bin || exit 1
}

case "$1" in
distro-cross)
	make_dc || exit 1
	;;
toolchain-host)
	INSTTEMP=${TCTREE} make_th || exit 1
	;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
	;;
esac
