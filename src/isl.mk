# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := isl
$(PKG)_WEBSITE  := https://libisl.sourceforge.io/
$(PKG)_DESCR    := Integer Set Library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.26
$(PKG)_CHECKSUM := a0b5cb06d24f9fa9e77b55fabbe9a3c94a336190345c2555f9915bb38e976504
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://libisl.sourceforge.io/$($(PKG)_FILE)
$(PKG)_URL_2    := https://gcc.gnu.org/pub/gcc/infrastructure/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc gmp

$(PKG)_DEPS_$(BUILD) := gmp

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gcc.gnu.org/pub/gcc/infrastructure/' | \
    $(SED) -n 's,.*isl-\([0-9][^>]*\)\.tar.*,\1,p' | \
    $(SORT) -V |
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-gmp-prefix='$(PREFIX)/$(TARGET)'
    $(MAKE) -C '$(1)' -j '$(JOBS)' $(if $(BUILD_SHARED),LDFLAGS=-no-undefined)
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
