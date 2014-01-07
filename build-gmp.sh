#!/bin/sh

# Automatic build script for GNU MP Bignum Library (GMP)
#  for i386 (iPhoneSimulator) and armv7(iPhoneOS)
#
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#

# You can change values here
#=================================================================================
# Library version
VERSION="5.1.3"
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

mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e gmp-${VERSION}.tar.bz2 ]; then
        echo "Downloading gmp-${VERSION}.tar.bz2"
        curl -O ftp://ftp.gnu.org/gnu/gmp/gmp-${VERSION}.tar.bz2
else
        echo "Using gmp-${VERSION}.tar.bz2"
fi
echo "Extracting files..."
tar zxf gmp-${VERSION}.tar.bz2 -C ${CURRENTPATH}/src/


for ((i=0; i<${#ARCHS[*]}; i++))
do
	ARCH=${ARCHS[i]}
	PLATFORM=${PLATFORMS[i]}
	SDKVERSION=${SDKVERSIONS[i]}

	OUTPUTPATH=${CURRENTPATH}/usr/${PLATFORM}${SDKVERSION}-${ARCH}.sdk
	mkdir -p "${OUTPUTPATH}"
	export PREFIX=${OUTPUTPATH}

	export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk
	#common toolchains for all platforms
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


	mkdir -p "${CURRENTPATH}/build/gmp-${ARCH}"
	cd ${CURRENTPATH}/build/gmp-${ARCH}

	echo "Configure..."
	${CURRENTPATH}/src/gmp-${VERSION}/configure --prefix=${PREFIX} --host=${ARCH}-apple-darwin --disable-assembly
	echo "Build..."
	make
	make install

	cd ${CURRENTPATH}
done

cd ${CURRENTPATH}
echo "Build library..."
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgmp.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgmp.a -output ${CURRENTPATH}/lib/libgmp.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgmp.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgmp.dylib -output ${CURRENTPATH}/lib/libgmp.dylib

echo "Copy headers..."
cp -r ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/include/* include

echo "Done"