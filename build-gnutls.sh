#!/bin/sh

# Automatic build script for GnuTLS (Transport Layer Security) library
#  for i386 (iPhoneSimulator) and armv7(iPhoneOS)
#
# Required:
#  1. Nettle library (build with GMP)
# 
# Note:
#  I cannot compile 3.2.x version (tested 3.2.8) of GnuTLS becouse (I think) it's need special pkg-config binaries to find nettle library.
#   When I set it directly I got another errors so I pass it, especially that branch 3.1.x have the lastest updates. 
#  It's needed to have xz binaries to extract files from tarball, you can build xz using provided script or install it by yourself (this script automatically detect proper binary).
#
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#
# You can change values here
#=================================================================================
# Library version
VERSION="3.1.18"
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


if which xz >/dev/null; 
then
    export XZAPP="xz"
else
	CURRARCH=`uname -m`
	if [ -f ${CURRENTPATH}/usr/${CURRARCH}.sdk/bin/xz ];
	then
    	export XZAPP="${CURRENTPATH}/usr/${CURRARCH}.sdk/bin/xz"
    else
    	echo "Please build xz first or install it by yourself"
    	exit 1
    fi
fi

if ! [ -f ${CURRENTPATH}/lib/libnettle.a ];
then
   	echo "Please build libnettle first"
   	exit 1
fi

mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e gnutls-${VERSION}.tar.xz ]; then
        echo "Downloading gnutls-${VERSION}.tar.xz"
        curl -O ftp://ftp.gnupg.org/gcrypt/gnutls/v3.1/gnutls-${VERSION}.tar.xz
else
        echo "Using gnutls-${VERSION}.tar.xz"
fi
echo "Extracting files..."
${XZAPP} -d gnutls-${VERSION}.tar.xz -k -f
tar zxf gnutls-${VERSION}.tar -C ${CURRENTPATH}/src/


for ((i=0; i<${#ARCHS[*]}; i++))
do
	ARCH=${ARCHS[i]}
	PLATFORM=${PLATFORMS[i]}
	SDKVERSION=${SDKVERSIONS[i]}
	
	# For testing purpose
	#ARCH="armv7"
	#PLATFORM="iPhoneOS"
	#SDKVERSION="7.0"
	#
	#ARCH="i386"
	#PLATFORM="iPhoneSimulator"
	#SDKVERSION="6.1"

	OUTPUTPATH=${CURRENTPATH}/usr/${PLATFORM}${SDKVERSION}-${ARCH}.sdk
	mkdir -p "${OUTPUTPATH}"
	export PREFIX=${OUTPUTPATH}

	export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk
	export DEVROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr

	export CC=$DEVROOT/bin/cc
	export LD=$DEVROOT/bin/ld
	export CXX=$DEVROOT/bin/c++
	export AS=$DEVROOT/bin/as

	export AR=$DEVROOT/bin/ar
	export NM=$DEVROOT/bin/nm

	export CPP="$DEVROOT/bin/clang -E"
	export CXXCPP="$DEVROOT/bin/clang -E"
	export RANLIB=$DEVROOT/bin/ranlib

	export CC_FOR_BUILD="/usr/bin/clang -isysroot / -I/usr/include"

	export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${PREFIX}/lib"
	export CCASFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export M4FLAGS="-I${PREFIX}/include"

	export CPPFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"


	mkdir -p "${CURRENTPATH}/build/gnutls-${ARCH}"
	cd ${CURRENTPATH}/build/gnutls-${ARCH}

	echo "Configure..."
	${CURRENTPATH}/src/gnutls-${VERSION}/configure --prefix=${PREFIX} --host=${ARCH}-apple-darwin --without-p11-kit
	echo "Build..."
	make
	make install

	cd ${CURRENTPATH}
	
done

cd ${CURRENTPATH}

echo "Build library..."
# libgnutls
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutls.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutls.a -output ${CURRENTPATH}/lib/libgnutls.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutls.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutls.dylib -output ${CURRENTPATH}/lib/libgnutls.dylib
# libgnutls-openssl
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutls-openssl.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutls-openssl.a -output ${CURRENTPATH}/lib/libgnutls-openssl.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutls-openssl.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutls-openssl.dylib -output ${CURRENTPATH}/lib/libgnutls-openssl.dylib
# libgnutls-xssl
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutls-xssl.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutls-xssl.a -output ${CURRENTPATH}/lib/libgnutls-xssl.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutls-xssl.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutls-xssl.dylib -output ${CURRENTPATH}/lib/libgnutls-xssl.dylib
# libgnutlsxx
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutlsxx.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutlsxx.a -output ${CURRENTPATH}/lib/libgnutlsxx.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgnutlsxx.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgnutlsxx.dylib -output ${CURRENTPATH}/lib/libgnutlsxx.dylib

echo "Copy headers..."
cp -r ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/include/* include

echo "Done"
