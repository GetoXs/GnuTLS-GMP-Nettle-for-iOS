#!/bin/sh

# Automatic build script for XZ utils
#  for actual architecture
#
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#=================================================================================	

if which xz >/dev/null; then
    echo "You don't need to build xz program"
    exit 0
fi

VERSION="5.0.5"

CURRENTPATH=${PWD}
ARCH=`uname -m`


mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e xz-${VERSION}.tar.bz2 ]; then
        echo "Downloading xz-${VERSION}.tar.bz2"
        curl -O http://tukaani.org/xz/xz-${VERSION}.tar.bz2
else
        echo "Using xz-${VERSION}.tar.bz2"
fi
echo "Extracting files..."
tar zxf xz-${VERSION}.tar.bz2 -C ${CURRENTPATH}/src/

OUTPUTPATH=${CURRENTPATH}/usr/${ARCH}.sdk
mkdir -p "${OUTPUTPATH}"
export PREFIX=${OUTPUTPATH}

mkdir -p "${CURRENTPATH}/build/xz"
cd ${CURRENTPATH}/build/xz

echo "Clear env variables"
unset SDKROOT
unset DEVROOT
unset CC_FOR_BUILD
unset LDFLAGS
unset CCASFLAGS
unset CFLAGS
unset CXXFLAGS
unset M4FLAGS
unset CPPFLAGS

echo "Configure..."
${CURRENTPATH}/src/xz-${VERSION}/configure --prefix=${PREFIX}

echo "Build..."
make
make install

cd ${CURRENTPATH}

echo "Done"
