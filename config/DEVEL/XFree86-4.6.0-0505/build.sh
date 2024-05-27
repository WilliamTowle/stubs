#!/bin/sh
# 2008-04-13 (prev 2007-04-22)

# Puppy 0.8.x build has LinuxLocaleDefines set to '-DX_LOCALE'

[ "${SYSCONF}" ] && . ${SYSCONF}
[ "${PKGFILE}" ] && . ${PKGFILE}

make_dc()
{
# CONFIGURE...
	PHASE=dc . ${TCTREE}/opt/freglx/bin/detect-config || exit 1

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

	case ${PKGVER} in
	4.[56].0)
		( cd xc/config/cf || exit 1
#		/* WmT */
#		#define KDriveXServer	YES
#		#define TinyXServer	YES
#		#define XfbdevServer	NO	/* WmT: site recommends YES */
#		#define XvesaServer	YES
#		
#		#define BuildFontServer	NO
#		#define BuildFontCache	NO
#		#define BuildFonts	NO
#		#define BuildXTrueType	NO
#		#define BuildLibraries	NO
#		#define BuildXawLibrary	NO
#		#define BuildXInputExt	NO
#		/* 4.2.1?
#		#define BuildXaw6	NO
#		#define SharedLibXaw	NO
#		#define NormalLibXaw	NO
#		*/
#		/*
#		#define BuildScreenSaverExt        NO
#		#define BuildScreenSaverLibrary    NO
#		*/
#		#define BuildLinuxDoc NO
#		
#		
#		#define UseXwctomb YES
#		#define HasLibCrypt YES
#		#define ForceNormalLib          YES
#		#define KdriveServerExtraDefines -DMAXSCREENS=3
#		
#		
#		#define CrossCompiling         YES
#		/* 2008-03-31: Looks useful for earlgrey/uClibc 0.9.20 -- #define BuildLowMem         YES */
			# Let's have a TinyX libraries and KDrive/Xvesa
			( cat <<EOF
#define OSName		Linux
#define OSMajorVersion	2
#define OSMinorVersion	0
#define OSTeenyVersion	40
#define HasZlib		NO

#define ProjectRoot	/usr/X11R6	/* WmT: except in toolchain? */
#define NothingOutsideProjectRoot	YES
#define UseSeparateConfDir	NO

/* for TinyXServer + BuildFonts... */
#define BuildServersOnly	YES
/* NB. KDrive does not support built-in fonts in XFree 4.5.0 */
#define BuildBuiltinFonts	YES
#define BuildDocs		NO

/* ...from http://lists.freedesktop.org/archives/xorg/2006-March/013788.html */
#define BuildLBX                NO
/* already do this #define BuildFonts              YES */
#define BuildAppgroup           NO
#define BuildDBE                NO
#define BuildXCSecurity         NO
#define FontServerAccess        NO
#undef BuildXF86RushExt
#define BuildXF86RushExt        NO
#undef BuildRender
#define BuildRender             YES
#define UseRgbTxt               YES
/* already do this #define BuildFontServer         NO */

/* echo '#define UseXwctomb	NO' */
EOF

			  echo '#define TinyXServer YES'
			  echo '#define KDriveXServer YES'
			  echo '#define XfbdevServer NO'
			  echo '#define XnestServer NO'
			  echo '#define XvesaServer YES'
			  echo '#define XTrioServer NO'
			  echo '#define XipaqServer NO'
			  echo '#define CrossCompiling YES'
			  echo '#define BuildIPv6 NO'
			  echo '#define BuildXawLibrary NO'
			  echo '#define BuildXcursorgen NO'

			# BuildFonts required for a first-time install
			# Servers only - assume other sources missing
			  cat xf86site.def \
				| sed '/define MakeDllModules/ { s%^%*/\n% ; s/YES/NO/ ; s%$%\n/*% }' \
				| sed '/define XdmxServer/ { s%^%*/\n% ; s/YES/NO/ ; s%$%\n/*% }' \
				| sed '/define XF86CardDrivers/ { s%^%*/\n% ; s%Drivers%Drivers vesa\n/*% }' \
				| sed '/define BuildFontServer/ { s%^%*/\n% ; s%$%\n/*% }' \
				| sed '/define BuildFonts/ { s%^%*/\n% ; s/NO/YES/ ; s%$%\n/*% }' \
				| sed '/not build.*fonts/,+5 { s%^#%*/\n#% ; s/YES/NO/ ; s%NO%NO\n/*% }' \
				| sed '/define BuildLinuxDoc/ { s%^%*/\n% ; s%$%\n/*% }'
			  ) > host.def || exit 1

			# OS{Major|Minor}Version will stop linux/input.h demand
			[ -r linux.cf.OLD ] || mv linux.cf linux.cf.OLD || exit 1
			( cat linux.cf.OLD \
				| sed '/define CompressAllFonts/	s/YES/NO/' \
				| sed '/define HaveTinyXIOPortSupport/ s/YES/NO/' \
				| sed '/define HaveTinyXVBESupport/ s/YES/NO/'
			  ) > linux.cf

			[ -r cross.def.OLD ] || mv cross.def cross.def.OLD || exit 1
			( cat cross.def.OLD \
				| sed 's/^#if 0/#if 1/' \
				| sed '/undef i386Architecture/ { s%^%/* % ; s%$% */% }' \
				| sed '/define Arm32Architecture/ { s%^%/* % ; s%$% */% }' \
				| sed '/define HasCplusplus/ s/YES/NO/' \
				| sed '/define HostCcCmd/ s%g*cc.*%'${FR_HOST_CC}'%' \
				| sed '/define CcCmd/ s%/.*%'${FR_CROSS_CC}'%' \
				| sed '/define StandardDefines/ s/-D__arm__//' \
				| sed '/define StdIncDir/ s%/.*%'${FR_LIBCDIR}'/include%' \
				| sed '/define PostIncDir/ s%/.*%'${FR_TC_ROOT}'/usr/lib/gcc-lib/'${TARGET_CPU}'-cross-linux/2.95.3/include%' \
				| sed '/define RanlibCmd/ s%/.*%'`echo ${FR_CROSS_CC} | sed 's/gcc$/ranlib/'`'%' \
			  ) > cross.def
#				| sed '/define LdPostLib/ s%/.*%'${FR_LIBCDIR}'/lib%'
		) || exit 1

		case ${USE_DISTRO}-${FR_TARGET_DEFN} in
		fr*uclibc)
			# adjust source[s] for uClibc - wide character support
			[ -r xc/lib/X11/Xlib.h.OLD ] || mv xc/lib/X11/Xlib.h xc/lib/X11/Xlib.h.OLD || exit 1
			cat xc/lib/X11/Xlib.h.OLD \
				| sed '/defined(ISC)/ s/defined.*/1/' \
				| sed '/define mbtowc/ { s%^%/* % ; s%$% */% }' \
				| sed '/define mblen/ s%$%\n#define mbtowc(a,b,c) _Xmbtowc(a,b,c)\n#define mbstowcs(a,b,c) _Xmbstowcs(a,b,c)%' \
				> xc/lib/X11/Xlib.h || exit 1 

			for SF in \
				xc/lib/X11/lcGenConv.c \
				xc/programs/Xserver/Xprint/Init.c \
				xc/programs/Xserver/Xprint/attributes.c \
			 ; do
				[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
				cat ${SF}.OLD \
					| sed 's%MB_CUR_MAX%sizeof(char) /* MB_CUR_MAX */%' \
					| sed 's/wchar_t/char/' \
					| sed 's%mbtowc%(char)/*mbtowc*/%' \
					> ${SF} || exit 1
			done

			# adjust source[s] for uClibc - large file support
			for SF in \
				xc/programs/Xserver/hw/xfree86/etc/mmapr.c \
				xc/programs/Xserver/hw/xfree86/etc/mmapw.c \
			; do
				[ -r ${SF}.OLD ] || mv ${SF} ${SF}.OLD || exit 1
				cat ${SF}.OLD \
					| sed '/define _FILE_OFFSET/	s/64/32/' \
					> ${SF} || exit 1
			done
		;;
		*)
			echo "$0: CONFIGURE: Unexpected USE_DISTRO/FR_TARGET_DEFN ${USE_DISTRO}, ${FR_TARGET_DEFN}"
			exit 1
		;;
		esac

		# oops!
		[ -r xc/include/extensions/lbxstr.h.OLD ] || mv xc/include/extensions/lbxstr.h xc/include/extensions/lbxstr.h.OLD || exit 1
		cat xc/include/extensions/lbxstr.h.OLD \
			| sed 's%<X11/extensions/XLbx.h>%"XLbx.h"%' \
			> xc/include/extensions/lbxstr.h || exit 1
	;;
	*)
		echo "$0: CONFIGURE: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac

# BUILD...
	case ${PKGVER} in
	4.[56].0)
		( cd xc || exit 1
			make CROSSCOMPILEDIR='' \
				XCURSORGEN=${PWD}/exports/bin/xcursorgen \
				World
		) || exit 1
	;;
	*)
		echo "$0: BUILD: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac


# INSTALL...
	case ${PKGVER} in
	4.[56].0)
		( cd xc || exit 1
			make DESTDIR=${INSTTEMP} install
		) || exit 1
	;;
	*)
		echo "$0: INSTALL: Unexpected PKGVER ${PKGVER}" 1>&2
		exit 1
	;;
	esac
}

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
