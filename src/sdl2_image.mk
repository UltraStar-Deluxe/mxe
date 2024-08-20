# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := sdl2_image
$(PKG)_WEBSITE  := https://www.libsdl.org/
$(PKG)_DESCR    := SDL2_image
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.8.2
$(PKG)_CHECKSUM := 8fd59b2c17772d7ac1192b11c645be8d7874f595c1714f4b200ee70b7cc38f3e
$(PKG)_GH_CONF  := libsdl-org/SDL_image/releases/tag,release-,,
$(PKG)_DEPS     := cc libjpeg-turbo libpng libwebp sdl2 tiff

define $(PKG)_BUILD
    $(SED) -i 's,^\(Requires:.*\),\1\nRequires.private: libtiff-4 libpng libwebp,' '$(1)/SDL2_image.pc.in'
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-sdl-prefix='$(PREFIX)/$(TARGET)' \
        --disable-sdltest \
        --disable-jpg-shared \
        --disable-webp-shared \
        --disable-png-shared \
        --disable-tif-shared \
        --disable-stb-image
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef
