#!/bin/sh
MXE=/tmp/mxe
TARGET=x86_64-w64-mingw32.shared
DLL_DIR=$MXE/DLLs
PORTAUDIO_NAME=portaudio_x64
if [ "`pwd`" != $MXE ] ; then
	echo Please clone this repository to /tmp/mxe for reproducible builds >&2
	exit 1
fi
touch src/ffmpeg.mk src/dav1d.mk src/freetype-bootstrap.mk src/libjpeg-turbo.mk src/libpng.mk src/portaudio.mk src/sqlite.mk src/lua.mk src/sdl2.mk src/sdl2_image.mk src/zlib.mk src/libwebp.mk src/tiff.mk
export SOURCE_DATE_EPOCH=0
# Replace local wrapper sources with USDX versions before building.
USDX_RAW_BASE="https://raw.githubusercontent.com/UltraStar-Deluxe/USDX/2b0ffa2e5e90b30e35f9f8f178a07a32033f451f"
fetch_wrapper() {
	url="$1"
	out="$2"
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL "$url" -o "$out"
		return $?
	fi
	if command -v wget >/dev/null 2>&1; then
		wget -qO "$out" "$url"
		return $?
	fi
	echo "Missing curl/wget to fetch USDX wrappers" >&2
	return 1
}
mkdir -p src/opencvwrapper src/projectm-cwrapper
fetch_wrapper "$USDX_RAW_BASE/src/lib/openCV3/ApiWrapper.cpp" \
	"src/opencvwrapper/opencv-wrapper.cpp"

# Force DWARF debug info and assume .loc support to avoid stabs on x86_64.
make MXE_TARGETS=$TARGET \
	CFLAGS_FOR_TARGET='-O2 -gdwarf-2 -gas-loc-support' \
	CXXFLAGS_FOR_TARGET='-O2 -gdwarf-2 -gas-loc-support' \
	ffmpeg sdl2_image freetype-bootstrap portaudio sqlite lua opencv opencvwrapper projectm
mkdir -p $DLL_DIR
OBJ_COPY="$MXE/usr/bin/$TARGET-objcopy"
add_dll() {
	dll="$1"
	base="$2"
	alias_opencv="$3"
	[ -x "$OBJ_COPY" ] || return 0
	[ -e "$dll" ] || return 0
	$OBJ_COPY --only-keep-debug "$dll" "$DLL_DIR/$base.debug"
	(
		cd "$DLL_DIR"
		set -- `md5sum "$base.debug"`
		k=$base-$1
		mv "$base.debug" "$k.debug"
		$OBJ_COPY -S --add-gnu-debuglink="$k.debug" "$dll" "$base.dll"
		chmod a-x "$base.dll" "$k.debug"
		if [ "$alias_opencv" = "alias_opencv" ] && [ "${base#opencv_}" != "$base" ]; then
			cp "$base.dll" "lib$base.dll"
		fi
	)
}
for i in avcodec-62 avformat-62 avutil-60 swresample-6 swscale-9 libdav1d libjpeg-8 libpng16-16 libtiff-6 libwebp-7 libsharpyuv-0 SDL2 SDL2_image zlib1 lua54 libsqlite3-0:sqlite3 libfreetype-6 libportaudio-2:$PORTAUDIO_NAME libbz2 libdl libgcc_s_seh-1 libstdc++-6 libwinpthread-1 projectM-4; do
	j=${i##*:}
	i=${i%%:*}
	DLL_PATH="$MXE/usr/$TARGET/bin/$i.dll"
	add_dll "$DLL_PATH" "$j"
done

# Add OpenCV and wrapper DLL(s) if present.
for dll in "$MXE/usr/$TARGET/bin"/opencv_*.dll "$MXE/usr/$TARGET/bin"/libopencv_*.dll "$MXE/usr/$TARGET/bin"/opencvwrapper.dll; do
	base=$(basename "$dll" .dll)
	add_dll "$dll" "$base"
done

$MXE/makeconfig.sh $MXE $TARGET > $DLL_DIR/config-win.inc
