#!/bin/sh -x
# 18/03/2006

#TODO: "cannot check for file existence when cross compiling" - /usr/share/X11/sgml/defs.ent

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	if [ -r ${TCTREE}/opt/freglx/bin/detect-config ] ; then
		# Ah, sanity! 2005-11-11 onward
		PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1
	else
#		echo "$0: CONFIGURE: Configuration not determined" 1>&2
		if [ -d ${TCTREE}/cross-utils ] ; then
			FR_TC_ROOT=${TCTREE}/cross-utils
			FR_TH_ROOT=${TCTREE}/host-utils
		else
			FR_TC_ROOT=${TCTREE}/
			FR_TH_ROOT=${TCTREE}/
		fi

		FR_KERNSRC=${FR_TC_ROOT}/usr/src/linux-2.0.40
		FR_LIBCDIR=${FR_TC_ROOT}/usr/${TARGET_CPU}-linux-uclibc
		if [ -r ${FR_TH_ROOT}/usr/bin/gcc ] ; then
			FR_HOST_CC=${FR_TH_ROOT}/usr/bin/gcc
		else
			FR_HOST_CC=`which gcc`
		fi
		FR_CROSS_CC=${FR_LIBCDIR}/bin/${TARGET_CPU}-uclibc-gcc
	fi

##	if [ ! -r ${FR_LIBCDIR}/include/ft2build.h ] ; then
##		echo "$0: Confused -- no freetype ft2build.h" 1>&2
##		exit 1
##	fi
#
#	if [ -r ${FR_LIBCDIR}/include/ncurses/ncurses.h ] ; then
#		# toolchain 0.7.x and later
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include/ncurses/'
#	elif [ -r ${FR_LIBCDIR}/include/ncurses.h ] ; then
#		# toolchain 0.6.4 and prior
#		ADD_INCL_NCURSES='-I'${FR_LIBCDIR}'/include'
#	else
#		echo "$0: Confused -- no ncurses.h" 1>&2
#		exit 1
#	fi
#
#	(	echo "#ifdef BeforeVendorCF"
#		echo "#undef HasGcc2"
#		echo "#define HasGcc2 YES"
#		echo "#undef HasCplusplus"
#		echo "#define HasCplusplus YES"
#		echo "#endif"
#		\
#		echo "#ifdef AfterVendorCF"
#		echo "#define ProjectRoot /usr/X11R6"
#		\
#		echo "#undef CrossCompiling"
#		echo "#define CrossCompiling YES"
#		\
#		echo "#undef HostCcCmd"
#		echo "#define HostCcCmd gcc"
#		echo "#undef CcCmd"
#		echo "#define CcCmd ${FR_CROSS_CC} ${ADD_INCL_NCURSES}"
#		echo "#define StdIncDir ${FR_LIBCDIR}"
#		echo "#undef CplusplusCmd"
#		echo "#define HasCplusplus YES"
#		echo "#define CplusplusCmd "`echo ${FR_CROSS_CC} | sed 's/cc$/++/'`
#		\
#		echo "#define BuildServersOnly YES"
#		echo "#define KDriveXServer YES"
#		#echo "#define TinyXServer YES"
#		#echo "#define XvesaServer NO"
#		#echo "#define XfbdevServer YES"
#		echo "#include <cross.rules>"
#		echo "#endif"
#		) > config/cf/site.def || exit 1

	case ${PKGVER} in
	1.0.1)
		CC=${FR_CROSS_CC} \
		  ac_cv_sys_linker_h=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
#		  ac_cv__usr_share_X11_sgml_defs_ent=no \
#			  --without-linuxdoc \
	;;
	1.2.0)
		ac_cv_file__usr_share_sgml_X11_defs_ent=no \
		  CC=${FR_CROSS_CC} \
		  ac_cv_sys_linker_h=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
#			  --without-linuxdoc \
	;;
	1.4)
		CC=${FR_CROSS_CC} \
		  ac_cv_sys_linker_h=no \
		  ac_cv_file__usr_share_sgml_X11_defs_ent=no \
			./configure --prefix=/usr \
			  --host=`uname -m` --build=${TARGET_CPU} \
			  || exit 1
#		  ac_cv__usr_share_X11_sgml_defs_ent=no \
#			  --without-linuxdoc \
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# BUILD...
	case ${PKGVER} in
	1.0.1|1.2.0)
		#make || exit 1
		# http://lists.freedesktop.org/archives/xorg/2004-October/003982.html
		make World CROSSCOMPILEDIR=${FR_LIBCDIR} || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

#	make CC=${FR_HOST_CC} BOOTSTRAPCFLAGS="-I../../include" World 2>&1 | tee world.log || exit 1
##	( cd config/imake && make CC=${FR_HOST_CC} CFLAGS="-I../../include" imake ) || exit 1
##
##	rm -rf `find ./ -name "*.[oa]"`
##	make World 2>&1 | tee world.log || exit 1

# INSTALL...
	case ${PKGVER} in
	1.0.1|1.2.0)
		make DESTDIR=${INSTTEMP} install 2>&1 | tee install.log \
			|| exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

}

#	[ -r config/cf/Imake.tmpl.OLD ] \
#		|| mv config/cf/Imake.tmpl config/cf/Imake.tmpl.OLD || exit 1
#	cat config/cf/Imake.tmpl.OLD \
#		| sed '/define HostCcCmd/ s/CcCmd.*/CcCmd gcc/' \
#		> config/cf/Imake.tmpl || exit 1
#
#	[ -r config/cf/cross.def.OLD ] \
#		|| mv config/cf/cross.def config/cf/cross.def.OLD || exit 1
#	cat config/cf/cross.def.OLD \
#		| sed '/define HostCcCmd/ s/CcCmd.*/CcCmd gcc/' \
#		| sed '/define CcCmd/ s%CcCmd.*%CcCmd '${FR_CROSS_CC}'-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#		> config/cf/cross.def || exit 1
#
#	[ -r config/cf/cross.rules.OLD ] \
#		|| mv config/cf/cross.rules config/cf/cross.rules.OLD || exit 1
#	cat config/cf/cross.rules.OLD \
#		| sed '/define HostCcCmd/ s/CcCmd.*/CcCmd gcc/' \
#		> config/cf/cross.rules || exit 1
#
#	[ -r config/cf/host.def.OLD ] \
#		|| mv config/cf/host.def config/cf/host.def.OLD 2>/dev/null
#	echo -n '' > config/cf/host.def
#	for FEATURE in \
#		'undef CrossCompiling' \
#		'define CrossCompiling YES' \
#		'define BuildServersOnly YES' \
#		'define ProjectRoot /usr/X11R6' \
#		\
#		'define KDriveXServer YES' \
#		'define TinyXServer YES' \
#		'define XvesaServer YES' \
#		-'define XfbdevServer YES' \
#		-'undef BuildLBX' \
#		-'define BuildLBX YES' \
#		-'undef BuildDBE' \
#		-'define BuildDBE YES' \
#		-'define KdriveServerExtraDefines -DPIXPRIV' \
#		-'define BuildRandR YES' \
#		-'define BuildXInputLib YES' \
#		-'define Freetype2Dir $(TOP)/extras/freetype2' \
#		-'define Freetype2LibDir $(TOP)/exports/lib' \
#		-'define BuildXTrueType YES' \
#		-'define BuildScreenSaverExt YES' \
#		-'define BuildScreenSaverLibrary YES' \
#		-'define SharedLibXss YES' \
#		-'define ServerXdmcpDefines' \
#		-'define HasShadowPasswd NO' \
#		-'define XFShadowFB NO' \
#		\
#		'ifndef HostCcCmd' \
#		'define HostCcCmd gcc' \
#		'endif' \
#		-'#define HasZLib NO' \
#		; do
#
#		case "${FEATURE}" in
#		[a-z]*)	echo "#$FEATURE" >> config/cf/host.def ;;
#		esac
#	done
#
#	[ -r config/cf/kdrive.cf.OLD ] \
#		|| mv config/cf/kdrive.cf config/cf/kdrive.cf.OLD || exit 1
#	cat config/cf/kdrive.cf.OLD \
#		| sed '/define TinyXServer/ s/TinyXServer.*/TinyXServer YES/' \
#		> config/cf/kdrive.cf || exit 1
#
#	[ -r config/cf/linux.cf.OLD ] \
#		|| mv config/cf/linux.cf config/cf/linux.cf.OLD || exit 1
#	cat config/cf/linux.cf.OLD \
#		| sed '/define CppCmd/ s%CppCmd.*%CppCmd '`echo ${FR_CROSS_CC} | sed 's/gcc$/cpp/'`'%' \
#		| sed '/define CcCmd/ s%CcCmd.*%CcCmd '${FR_CROSS_CC}'-nostdinc -I'${FR_LIBCDIR}'/include -I'${GCCINCDIR}' -I'${TCTREE}'/usr/include %' \
#		| sed '/define AsCmd/ s%AsCmd.*%AsCmd '`echo ${FR_CROSS_CC} | sed 's/gcc$/as/'`'%' \
#		| sed '/define LdCmd/ s%LdCmd.*%LdCmd '`echo ${FR_CROSS_CC} | sed 's/gcc$/ld/'`'%' \
#		| sed '/define CplusplusCmd/ s%CplusplusCmd.*%CplusplusCmd '`echo ${FR_CROSS_CC} | sed 's/cc$/++/'`'%' \
#		| sed '/define AsmDefines/ s%AsmDefines.*%AsmDefines -D__ELF__%' \
#		| sed '/define HasPam/ s%HasPam.*%HasPam NO%' \
#		| sed '/define HasShadowPasswd/ s%HasShadowPasswd.*%HasShadowPasswd NO%' \
#		| sed '/define HasTcl/ s%HasTcl.*%HasTcl NO%' \
#		| sed '/define HasTk/ s%HasTk.*%HasTk NO%' \
#		| sed '/define HasLibCrypt/ s%HasLibCrypt.*%HasLibCrypt NO%' \
#		> config/cf/linux.cf || exit 1
#	#echo '#define CrossCompiling YES' >> config/cf/linux.cf || exit 1
#
## BUILD...
##	( cd programs/Xserver && make clean && make ) || exit 1
##	make CFLAGS="-I"${HERE}"/lib -O2 -fno-strength-reduce    -I. -I../../../../exports/include/X11 -I../../../../include/fonts     -I./../../fb -I./../../mi -I./../../Xext        -I./../../miext/shadow -I./../../miext/layer    -I./../../include -I./../../os          -I../../../../include/extensions -I../../../../exports/include/X11 -I./../../render -I./../../randr  -I../../../.. -I../../../../exports/include -I/usr/X11R6/include" World || exit 1
#	CC=${FR_HOST_CC} make World || exit 1
##	make World || exit 1

case "$1" in
distro-cross)
	make_dc || exit 1
;;
#toolchain)
#	INSTTEMP=${TCTREE} make_th || exit 1
#;;
*)
	echo "$0: Unexpected ARG '$1'" 1>&2
	exit 1
;;
esac
