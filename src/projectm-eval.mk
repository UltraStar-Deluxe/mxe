# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := projectm-eval
$(PKG)_WEBSITE  := https://github.com/projectM-visualizer/projectm-eval
$(PKG)_DESCR    := projectM-eval
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.6
$(PKG)_CHECKSUM := d663f7fc2c6962e29d5f3977f22c9a988e01638911e0efabea6b7ed4dcb0a8ce
$(PKG)_URL := https://github.com/projectM-visualizer/projectm-eval/archive/refs/tags/v$($(PKG)_VERSION).tar.gz
$(PKG)_FILE     := projectm-eval-$($(PKG)_VERSION).tar.gz

define $(PKG)_BUILD
    cd '$(1)'
    cp -r '$(1)/projectm-eval-$($(PKG)_VERSION)/' '$(PREFIX)/$(TARGET)/share/projectm-eval'
endef
