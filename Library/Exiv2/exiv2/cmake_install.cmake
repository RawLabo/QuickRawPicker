# Install script for directory: C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/exiv2")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/exiv2" TYPE FILE FILES
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/asfvideo.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/basicio.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/bmffimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/bmpimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/config.h"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/convert.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/cr2image.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/crwimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/datasets.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/easyaccess.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/epsimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/error.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/exif.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/exiv2.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/futils.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/gifimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/http.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/image.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/ini.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/iptc.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/jp2image.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/jpgimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/matroskavideo.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/metadatum.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/mrwimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/orfimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/pgfimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/pngimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/preview.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/properties.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/psdimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/quicktimevideo.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/rafimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/riffvideo.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/rw2image.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/rwlock.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/slice.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/ssh.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/tags.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/tgaimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/tiffimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/types.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/utilsvideo.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/value.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/version.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/webpimage.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/xmp_exiv2.hpp"
    "C:/Users/qdwang/Desktop/exiv2-0.27.4-RC2/include/exiv2/xmpsidecar.hpp"
    )
endif()

