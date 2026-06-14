#!/bin/bash
MXE=${1:-.}
TARGET=${2:-x86_64-w64-mingw32.shared}
CC=$MXE/usr/bin/$TARGET-gcc
NM=$MXE/usr/bin/$TARGET-nm
OBJCOPY=$MXE/usr/bin/$TARGET-objcopy
DLLTOOL=$MXE/usr/bin/$TARGET-dlltool
PKGCONFIG=$MXE/usr/bin/$TARGET-pkg-config

get_dll()
{
	symbol="$1"
	shift
	for lib ; do
		for implib in $lib.dll.a $lib.a ; do
			for dir in $MXE/usr/lib/gcc/$TARGET/*/ $MXE/usr/$TARGET/lib/ ; do
				if [ -e $dir/$implib ] ; then
					if $NM -C -g --defined-only $dir/$implib | grep -q " $symbol$" ; then
						if $DLLTOOL --identify-strict -I $dir/$implib ; then
							return
						fi
					fi
				fi
			done
		done
	done
}

pkg_libs()
{
	set -- `$PKGCONFIG --libs "$@"`
	for arg ; do
		case "$arg" in
		-l*) echo lib${arg#-l}
		esac
	done
}

pkg_version()
{
	ver=`$PKGCONFIG --modversion $1`
	eval "$2=$ver"
	ver=$ver.0.0
	i=0
	for part in MAJOR MINOR RELEASE ; do
		v=${ver%%.*}
		ver=${ver#*.}
		i=$((i*1000+v))
		eval "${2}_$part=$v"
	done
	eval "${2}_INT=$i"
}

get_c_bool()
{
	exp="$1"
	shift
	file=/tmp/conftest-$$.c
	while [ $# -gt 0 ] ; do
		if [ "$1" == -- ] ; then
			shift
			break;
		fi
		echo "$1"
		shift
	done > $file
	echo "struct x {unsigned a:($exp)?1:-1;};" >> $file
	$CC "$@" -S -o - $file >/dev/null 2>/dev/null
	ret=$?
	rm -f $file
	return $ret
}

get_c_uinteger()
{
	num="$1"
	shift
	cur=0
	bit=1
	while get_c_bool "($num) > ${cur}UL" "$@"; do
		while ! get_c_bool "($num) & ${bit}UL" "$@"; do
			bit=$((bit*2))
		done
		cur=$((cur+bit))
		bit=$((bit*2))
	done
	echo $cur
}

LUA_LIB_NAME=$(get_dll luaL_newstate $(pkg_libs lua))
pkg_version lua LUA_VERSION

av__codec=$(get_dll avcodec_version $(pkg_libs libavcodec))
pkg_version libavcodec LIBAVCODEC_VERSION

av__format=$(get_dll avformat_version $(pkg_libs libavformat))
pkg_version libavformat LIBAVFORMAT_VERSION

av__util=$(get_dll avutil_version $(pkg_libs libavutil))
pkg_version libavutil LIBAVUTIL_VERSION

sw__resample=$(get_dll swr_convert $(pkg_libs libswresample))
pkg_version libswresample LIBSWRESAMPLE_VERSION

sw__scale=$(get_dll sws_scale $(pkg_libs libswscale))
pkg_version libswscale LIBSWSCALE_VERSION

pkg_version projectM-4 PROJECTM_VERSION
pkg_version portaudio-2.0 PORTAUDIO_VERSION

# Works for all FFmpeg version supported by current USDX
FFMPEG_DIR="ffmpeg-$(($LIBAVUTIL_VERSION_MAJOR-52)).0"

LUA_INTEGER_BYTES=$(get_c_uinteger "sizeof(lua_Integer)" "#include <lua.h>" -- $($PKGCONFIG --cflags lua))
LUA_INTEGER_BITS=$(($LUA_INTEGER_BYTES*8))

cat <<EOF
{*****************************************************************
 * Configuration file for UltraStar Deluxe
 *****************************************************************}

{* Libraries *}

{\$IF Defined(IncludeConstants)}
  LUA_LIB_NAME        = '${LUA_LIB_NAME}';
  LUA_VERSION_INT     = ${LUA_VERSION_INT};
  LUA_VERSION_RELEASE = '${LUA_VERSION_RELEASE}';
  LUA_VERSION_MINOR   = '${LUA_VERSION_MINOR}';
  LUA_VERSION_MAJOR   = '${LUA_VERSION_MAJOR}';
  LUA_VERSION         = '${LUA_VERSION}';
  LUA_INTEGER_BITS    = ${LUA_INTEGER_BITS};
{\$IFEND}

{\$DEFINE HaveFFmpeg}
//the required DLLs can be built with MXE
{\$IF Defined(HaveFFmpeg)}
  {\$MACRO ON}
  {\$IFNDEF FFMPEG_DIR}
    {\$DEFINE FFMPEG_DIR := '${FFMPEG_DIR}'}
  {\$ENDIF}
  {\$IF Defined(IncludeConstants)}
    av__codec = '${av__codec}';
    LIBAVCODEC_VERSION_MAJOR   = ${LIBAVCODEC_VERSION_MAJOR};
    LIBAVCODEC_VERSION_MINOR   = ${LIBAVCODEC_VERSION_MINOR};
    LIBAVCODEC_VERSION_RELEASE = ${LIBAVCODEC_VERSION_RELEASE};

    av__format = '${av__format}';
    LIBAVFORMAT_VERSION_MAJOR   = ${LIBAVFORMAT_VERSION_MAJOR};
    LIBAVFORMAT_VERSION_MINOR   = ${LIBAVFORMAT_VERSION_MINOR};
    LIBAVFORMAT_VERSION_RELEASE = ${LIBAVFORMAT_VERSION_RELEASE};

    av__util = '${av__util}';
    LIBAVUTIL_VERSION_MAJOR   = ${LIBAVUTIL_VERSION_MAJOR};
    LIBAVUTIL_VERSION_MINOR   = ${LIBAVUTIL_VERSION_MINOR};
    LIBAVUTIL_VERSION_RELEASE = ${LIBAVUTIL_VERSION_RELEASE};
  {\$IFEND}
{\$IFEND}

{\$DEFINE HaveSWResample}
{\$IF Defined(HaveSWScale) and Defined(IncludeConstants)}
  sw__resample = '${sw__resample}';
  LIBSWRESAMPLE_VERSION_MAJOR   = ${LIBSWRESAMPLE_VERSION_MAJOR};
  LIBSWRESAMPLE_VERSION_MINOR   = ${LIBSWRESAMPLE_VERSION_MINOR};
  LIBSWRESAMPLE_VERSION_RELEASE = ${LIBSWRESAMPLE_VERSION_RELEASE};
{\$IFEND}

{\$DEFINE HaveSWScale}
{\$IF Defined(HaveSWScale) and Defined(IncludeConstants)}
  sw__scale = '${sw__scale}';
  LIBSWSCALE_VERSION_MAJOR   = ${LIBSWSCALE_VERSION_MAJOR};
  LIBSWSCALE_VERSION_MINOR   = ${LIBSWSCALE_VERSION_MINOR};
  LIBSWSCALE_VERSION_RELEASE = ${LIBSWSCALE_VERSION_RELEASE};
{\$IFEND}

{\$DEFINE HaveProjectM}
{\$IF Defined(HaveProjectM) and Defined(IncludeConstants)}
  ProjectM_DataDir = 'visuals\projectM';
  PROJECTM_VERSION_MAJOR   = ${PROJECTM_VERSION_MAJOR};
  PROJECTM_VERSION_MINOR   = ${PROJECTM_VERSION_MINOR};
  PROJECTM_VERSION_RELEASE = ${PROJECTM_VERSION_RELEASE};
{\$IFEND}

{\$UNDEF HavePortaudio}
{\$IF Defined(HavePortaudio) and Defined(IncludeConstants)}
  PORTAUDIO_VERSION_MAJOR   = ${PORTAUDIO_VERSION_MAJOR};
  PORTAUDIO_VERSION_MINOR   = ${PORTAUDIO_VERSION_MINOR};
  PORTAUDIO_VERSION_RELEASE = ${PORTAUDIO_VERSION_RELEASE};
{\$IFEND}

{\$UNDEF HavePortmixer}

{\$DEFINE UsePortMidi}
{\$IF Defined(UsePortMidi)}
  {\$DEFINE UseMIDIPort}
{\$IFEND}
{\$IF Defined(UseMidiEmu)}
  {\$DEFINE UseMidiEmu}
  {\$DEFINE UseMIDIPort}
  // Avoid platform MIDI backends with system synths if built-in MIDI emulation is enabled
  {\$UNDEF UsePortMidi}
  {\$UNDEF UsePortTime}
{\$IFEND}

{\$DEFINE UseOpenCVWrapper}
EOF
