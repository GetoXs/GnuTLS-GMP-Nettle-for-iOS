GnuTLS-GMP-Nettle-for-iOS
=========================
####Overview:####
GnuTLS 3.1.* build scripts for iPhoneOS and iPhoneSimulator using official XCode toolchain and SDK from Apple.
Please read all this readme before you start.

Result files will be in created lib/ and include/ directories for i386 and armv7 architectures.
To use the libraries, include the library from lib/ directory and headers from include/.

If you have any problem don't hesitate to contact to me.

 
####Note for GnuTLS 3.2.* version:####
I couldn't compile 3.2.* version (tested 3.2.8) of GnuTLS becouse (I think) it's need special pkg-config binaries to find Nettle library.
 

####License:####
Under LICENSE file

 
####Install:####

 1. build-gmp
 2. build-nettle
 3. If you don't have XZ utils in system => build-xz
 4. build-gnutls
 5. You have all libraries in lib/ and include/ directories
 
 
####Output structure:####
Build scripts will create in current folder with additional structure:

  * build/    -configured build files for every library and architecture
  * lib/		-output libs (merged for all configured architectures)
  * include/	-output headers
  * src/		-source files (extracted from tarballs)
  * tar/		-tarball files
  * usr/		-build files for every configured platform (includes, libs, shares, manuals)


####Tested versions (without errors) on:####
* OSX	10.8.5
* Xcode	5.0

* GMP 	5.1.3
* Nettle	2.7.1
* XZ		5.0.5
* GnuTLS	3.1.18
  

####Usefull tools:####
* xcrun - to locate development tools and properties for specyfied platform
 >+ eg: 	Locate C compiler for iPhoneOS: 
		`xcrun find -sdk iphoneos cc`
* lipo - to create, merge and operate on files
 >+ eg: 	Merge libraries with different architectures into one universal file: 
		`lipo -create usr.i386/lib/libgmp.a usr.armv7/lib/libgmp.a -output lib/libgmp.a`
* uname - print system name
 >+ eg: 	Print actual architecture: 
		`uname -m`

###Thanks to:###
* Really helpful build scripts, but for older version of GnuTLS:
>* <https://github.com/yep/gnutls-gpg-gpgme-for-ios>
>* <https://github.com/x2on/GnuTLS-for-iOS>
>* <https://gist.github.com/morgant/1753095>

* Cross-Compiling information:
>* <http://tinsuke.wordpress.com/2011/02/17/how-to-cross-compiling-libraries-for-ios-armv6armv7i386/>
>* <https://ghc.haskell.org/trac/ghc/wiki/Building/CrossCompiling/iOS>
>* <http://wiki.osdev.org/GCC_Cross-Compiler>

* Information about NEON instruction set:
>* <http://www.shervinemami.info/armAssembly.html#template>