# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := projectm
$(PKG)_WEBSITE  := https://github.com/projectM-visualizer/projectm
$(PKG)_DESCR    := projectM
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.1.6
$(PKG)_SHA := 4d2849333b63235a6af4d1f02508a97529d96dc7
$(PKG)_CHECKSUM := 218e1e5042ae4caaf7b17497722e9a04b4844444a6e2844f58ddce0c805043ea
$(PKG)_URL := https://github.com/projectM-visualizer/projectm/archive/$($(PKG)_SHA).tar.gz
$(PKG)_SUBDIR   := projectm-$($(PKG)_SHA)
$(PKG)_FILE     := libprojectM-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc projectm-eval

define $(PKG)_BUILD
    cp -r $(PREFIX)/$(TARGET)/share/projectm-eval '$(1)/vendor'
    cd '$(1)'
    $(TARGET)-cmake -S '$(1)' -B '$(1)/build' -DENABLE_PLAYLIST=OFF
    $(MAKE) -C '$(1)/build' -j '$(JOBS)' $(MXE_DISABLE_CRUFT) install
    echo -e 'Name: projectM-4\nVersion: $($(PKG)_VERSION)\nDescription: projectM Music Visualizer' > '$(1)/projectM-4.pc'
    mv '$(PREFIX)/$(TARGET)/bin/libprojectM-4.dll' '$(PREFIX)/$(TARGET)/bin/projectM-4.dll'
    $(INSTALL) '$(1)/projectM-4.pc' '$(PREFIX)/$(TARGET)/lib/pkgconfig'
endef
