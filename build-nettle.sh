#!/bin/sh

# Automatic build script for Nettle (low-level cryptographic) library
#  for i386 (iPhoneSimulator) and armv7(iPhoneOS)
#
# Required:
#  1. GMP library
# 
# Note:
#  There was problem with arm-neon instruction set and also with additional aes/sha assembler files that's why I disabled these features in configuration process.
#
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#
# You can change values here
#=================================================================================
# Library version
VERSION="2.7.1"
# Architectures array
ARCHS=("i386" "armv7")
# Platforms array
PLATFORMS=("iPhoneSimulator" "iPhoneOS")
# SDK versions array
SDKVERSIONS=("6.1" "7.0")
#=================================================================================
#
# You don't need to change values here
#=================================================================================

CURRENTPATH=${PWD}

if ! [ -f ${CURRENTPATH}/lib/libgmp.a ];
then
   	echo "Please build libgmp first"
   	exit 1
fi

mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e nettle-${VERSION}.tar.gz ]; then
        echo "Downloading nettle-${VERSION}.tar.gz"
        curl -O http://www.lysator.liu.se/~nisse/archive/nettle-${VERSION}.tar.gz
else
        echo "Using nettle-${VERSION}.tar.gz"
fi
echo "Extracting files..."
tar zxf nettle-${VERSION}.tar.gz -C ${CURRENTPATH}/src/


for ((i=0; i<${#ARCHS[*]}; i++))
do
	ARCH=${ARCHS[i]}
	PLATFORM=${PLATFORMS[i]}
	SDKVERSION=${SDKVERSIONS[i]}

	OUTPUTPATH=${CURRENTPATH}/usr/${PLATFORM}${SDKVERSION}-${ARCH}.sdk
	mkdir -p "${OUTPUTPATH}"
	export PREFIX=${OUTPUTPATH}

	export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk
	# export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/usr
	# export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr
	export DEVROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr

	export CC=$DEVROOT/bin/cc
	export LD=$DEVROOT/bin/ld
	export CXX=$DEVROOT/bin/c++
	# alias
	export AS=$DEVROOT/bin/as
	# alt
	# export AS=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/libexec/as/x86_64/as

	export AR=$DEVROOT/bin/ar
	# alias
	export NM=$DEVROOT/bin/nm
	# alt
	# export NM="$DEVROOT/bin/nm -arch ${ARCH}"

	#export CPP=$DEVROOT/bin/cpp
	export CPP="$DEVROOT/bin/clang -E"
	#export CXXCPP=$DEVROOT/bin/cpp
	export CXXCPP="$DEVROOT/bin/clang -E"
	# alias as libtool
	export RANLIB=$DEVROOT/bin/ranlib

	export CC_FOR_BUILD="/usr/bin/clang -isysroot / -I/usr/include"

	export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${PREFIX}/lib"
	export CCASFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export M4FLAGS="-I${PREFIX}/include"

	export CPPFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"


	mkdir -p "${CURRENTPATH}/build/nettle-${ARCH}"
	cd ${CURRENTPATH}/build/nettle-${ARCH}

	echo "Configure..."
	${CURRENTPATH}/src/nettle-${VERSION}/configure --prefix=${PREFIX} --host=${ARCH}-apple-darwin --disable-openssl --disable-assembler --disable-arm-neon
	echo "Build..."
	make
	make install

	cd ${CURRENTPATH}
done

cd ${CURRENTPATH}
echo "Build library..."
# libnettle
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libnettle.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libnettle.a -output ${CURRENTPATH}/lib/libnettle.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libnettle.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libnettle.dylib -output ${CURRENTPATH}/lib/libnettle.dylib
# libhogweed
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libhogweed.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libhogweed.a -output ${CURRENTPATH}/lib/libhogweed.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libhogweed.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libhogweed.dylib -output ${CURRENTPATH}/lib/libhogweed.dylib

echo "Copy headers..."
cp -r ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/include/* include

echo "Done"
