# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := opencv
$(PKG)_WEBSITE  := https://opencv.org/
$(PKG)_DESCR    := OpenCV
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.13.0
$(PKG)_CHECKSUM := 1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d
$(PKG)_GH_CONF  := opencv/opencv/releases
$(PKG)_DEPS     := cc libjpeg-turbo

# -DCMAKE_CXX_STANDARD=98 required for non-posix gcc7 build

define $(PKG)_BUILD
    # build
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
      -DWITH_QT=OFF \
      -DWITH_OPENGL=ON \
      -DWITH_FFMPEG=OFF \
      -DWITH_GSTREAMER=OFF \
      -DWITH_GTK=OFF \
      -DWITH_VIDEOINPUT=ON \
      -DWITH_XINE=OFF \
      -DWITH_LAPACK=OFF \
      -DWITH_EIGEN=OFF \
      -DWITH_OPENBLAS=OFF \
      -DWITH_IPP=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_opencv_calib3d=OFF \
      -DBUILD_opencv_dnn=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_opencv_features2d=OFF \
      -DBUILD_opencv_flann=OFF \
      -DBUILD_opencv_gapi=OFF \
      -DBUILD_opencv_highgui=OFF \
      -DBUILD_opencv_java_bindings_generator=OFF \
      -DBUILD_opencv_ml=OFF \
      -DBUILD_opencv_objdetect=OFF \
      -DBUILD_opencv_photo=OFF \
      -DBUILD_opencv_python2=OFF \
      -DBUILD_opencv_python_bindings_generator=OFF \
      -DBUILD_opencv_python_tests=OFF \
      -DBUILD_PACKAGE=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_opencv_stitching=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_opencv_ts=OFF \
      -DBUILD_opencv_video=OFF \
      -DBUILD_WITH_DEBUG_INFO=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DCV_TRACE=OFF \
      -DBUILD_ZLIB=OFF \
      -DBUILD_TIFF=OFF \
      -DBUILD_JASPER=OFF \
      -DBUILD_JPEG=OFF \
      -DBUILD_WEBP=OFF \
      -DBUILD_PROTOBUF=OFF \
      -DBUILD_PNG=OFF \
      -DBUILD_OPENEXR=OFF \
      -DWITH_JPEG=ON \
      -DWITH_PNG=OFF \
      -DWITH_TIFF=OFF \
      -DWITH_WEBP=OFF \
      -DWITH_JASPER=OFF \
      -DWITH_OPENJPEG=OFF \
      -DWITH_OPENEXR=OFF \
      -DWITH_PROTOBUF=OFF \
      -DWITH_ZLIB=OFF \
      -DWITH_ADE=OFF \
      -DWITH_QUIRC=OFF \
      -DWITH_GDAL=OFF \
      -DWITH_GDCM=OFF \
      -DWITH_IMGCODEC_HDR=OFF \
      -DWITH_IMGCODEC_SUNRASTER=OFF \
      -DWITH_IMGCODEC_PXM=OFF \
      -DWITH_IMGCODEC_PFM=OFF \
      -DCMAKE_VERBOSE=ON \
      -DOPENCV_GENERATE_PKGCONFIG=ON

    # install
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    $(INSTALL) -m755 '$(BUILD_DIR)/unix-install/opencv4.pc' '$(PREFIX)/$(TARGET)/lib/pkgconfig'

endef
