# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ffmpeg
$(PKG)_WEBSITE  := https://ffmpeg.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 7.0.2
$(PKG)_CHECKSUM := 8646515b638a3ad303e23af6a3587734447cb8fc0a0c064ecdb8e95c4fd8b389
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://ffmpeg.org/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := cc dav1d yasm zlib

# DO NOT ADD fdk-aac OR openssl SUPPORT.
# Although they are free softwares, their licenses are not compatible with
# the GPL, and we'd like to enable GPL in our default ffmpeg build.
# See docs/index.html#potential-legal-issues

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ffmpeg.org/releases/' | \
    $(SED) -n 's,.*ffmpeg-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc\|git' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        --cross-prefix='$(TARGET)'- \
        --enable-cross-compile \
        --arch=$(firstword $(subst -, ,$(TARGET))) \
        --target-os=mingw32 \
        --prefix='$(PREFIX)/$(TARGET)' \
        $(if $(BUILD_STATIC), \
            --enable-static --disable-shared , \
            --disable-static --enable-shared ) \
        --x86asmexe='$(TARGET)-yasm' \
        --enable-debug \
        --disable-stripping \
        --disable-pthreads \
        --enable-w32threads \
        --disable-doc \
        --enable-libdav1d \
        --enable-version3 \
        --extra-libs='-mconsole' \
        --disable-programs \
        --disable-doc \
        --disable-encoders \
        --disable-iconv \
        --disable-xlib \
        --disable-libxcb \
        --disable-libxcb-shm \
        --disable-libx264 \
        --disable-libx265 \
        --disable-network \
        --disable-indevs \
        --disable-outdevs \
        --disable-postproc \
        --disable-muxers \
        --disable-bsfs \
        --disable-filters \
        --disable-protocols \
        --disable-lzma \
        --disable-bzlib \
        --extra-ldflags="-fstack-protector -static-libgcc" \
        $($(PKG)_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
