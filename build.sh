#!/bin/sh
MXE=/tmp/mxe
if [ "`pwd`" != $MXE ] ; then
	echo Please clone this repository to /tmp/mxe for reproducible builds >&2
	exit 1
fi
touch src/ffmpeg.mk src/dav1d.mk src/freetype-bootstrap.mk src/libjpeg-turbo.mk src/libpng.mk src/portaudio.mk src/sqlite.mk src/lua.mk src/sdl2.mk src/sdl2_image.mk src/zlib.mk src/libwebp.mk src/tiff.mk
export SOURCE_DATE_EPOCH=0
make -j 2 JOBS=2 MXE_TARGETS=i686-w64-mingw32.shared ffmpeg sdl2_image freetype-bootstrap portaudio sqlite lua
mkdir -p $MXE/DLLs
for i in avcodec-61 avformat-61 avutil-59 swresample-5 swscale-8 libdav1d libjpeg-8 libpng16-16 libtiff-6 libwebp-7 SDL2 SDL2_image zlib1 lua54:lua5.4 libsqlite3-0:sqlite3 libfreetype-6:freetype6 libportaudio-2:portaudio_x86 ; do
	j=${i##*:}
	i=${i%%:*}
	$MXE/usr/bin/i686-w64-mingw32.shared-objcopy --only-keep-debug $MXE/usr/i686-w64-mingw32.shared/bin/$i.dll $MXE/DLLs/$j.debug
	(
		cd $MXE/DLLs
		set -- `md5sum $j.debug`
		k=$j-$1
		mv $j.debug $k.debug
		$MXE/usr/bin/i686-w64-mingw32.shared-objcopy -S --add-gnu-debuglink=$k.debug $MXE/usr/i686-w64-mingw32.shared/bin/$i.dll $j.dll
		chmod a-x $j.dll $k.debug
	)
done
