#!/bin/sh

# ffmpeg static build 2.8

set -e
set -u
echo
date +%H:%M:%S

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo && /bin/echo -e "\e[93m Reconfiguring existing packages...\e[39m" && echo
[ $is_x86 -ne 1 ] && echo && /bin/echo -e "\e[93m Not using yasm or nasm on non-x86 platform...\e[39m" && echo

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo
/bin/echo -e "\e[93m#### FFmpeg static build ####\e[39m"
echo

#this is our working directory
cd $BUILD_DIR

[ $is_x86 -eq 1 ] && download \
  "yasm-1.3.0.tar.gz" \
  "" \
  "fc9e586751ff789b34b1f21d572d96af" \
  "http://www.tortall.net/projects/yasm/releases/"

[ $is_x86 -eq 1 ] && download \
  "nasm-2.14.tar.gz" \
  "" \
  "bc1cdaa06fc522eefa35c4ba881348f5" \
  "http://www.nasm.us/pub/nasm/releasebuilds/2.14/"

download \
  "v1.2.5.tar.gz" \
  "zlib-1.2.5.tar.gz" \
  "9d8bc8be4fb6d9b369884c4a64398ed7" \
  "https://github.com/madler/zlib/archive/"

download \
  "master.tar.gz" \
  "libjpeg-turbo-master.tar.gz" \
  "nil" \
  "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/"

download \
  "master.tar.gz" \
  "libpng-master.tar.gz" \
  "nil" \
  "https://github.com/glennrp/libpng/archive/"

download \
  "v1.2.11.tar.gz" \
  "zlib-1.2.11.tar.gz" \
  "0095d2d2d1f3442ce1318336637b695f" \
  "https://github.com/madler/zlib/archive/"

download \
  "dev.tar.gz" \
  "zstd-dev.tar.gz" \
  "nil" \
  "https://github.com/facebook/zstd/archive/"

download \
  "v1.1.0.tar.gz" \
  "libwebp-1.1.0.tar.gz" \
  "35831dd0f8d42119691eb36f2b9d23b7" \
  "https://github.com/webmproject/libwebp/archive/"

download \
  "tiff-4.1.0.tar.gz" \
  "" \
  "nil" \
  "http://download.osgeo.org/libtiff/"

#download \
#  "util-macros-1.19.2.tar.gz" \
#  "" \
#  "5059b328fac086b733ffac6607164c41" \
#  "https://www.x.org/archive//individual/util/"

#download \
#  "xorgproto-2019.1.tar.bz2" \
#  "" \
#  "802ccb9e977ba3cf94ba798ddb2898a4" \
#  "https://xorg.freedesktop.org/archive/individual/proto/"

download \
  "tk8.6.10-src.tar.gz" \
  "" \
  "602a47ad9ecac7bf655ada729d140a94" \
  "https://netix.dl.sourceforge.net/project/tcl/Tcl/8.6.10/"

download \
  "tcl8.6.10-src.tar.gz" \
  "" \
  "97c55573f8520bcab74e21bfd8d0aadc" \
  "https://netcologne.dl.sourceforge.net/project/tcl/Tcl/8.6.10/"

download \
  "master.tar.gz" \
  "libexpat-master.tar.gz" \
  "nil" \
  "https://github.com/libexpat/libexpat/archive/"

download \
  "Python-2.7.17.tar.xz" \
  "" \
  "b3b6d2c92f42a60667814358ab9f0cfd" \
  "https://www.python.org/ftp/python/2.7.17/"

download \
  "libxml2-2.9.10.tar.gz" \
  "" \
  "10942a1dc23137a8aa07f0639cbfece5" \
  "http://xmlsoft.org/sources/"

download \
  "freetype-2.10.1.tar.xz" \
  "" \
  "bd42e75127f8431923679480efb5ba8f" \
  "https://downloads.sourceforge.net/freetype/"

download \
  "fontconfig-2.13.92.tar.xz" \
  "" \
  "d5431bf5456522380d4c2c9c904a6d96" \
  "https://www.freedesktop.org/software/fontconfig/release/"

download \
  "imlib2-1.6.1.tar.bz2" \
  "" \
  "7b3fbcb974b48822b32b326c6a47764b" \
  "https://netix.dl.sourceforge.net/project/enlightenment/imlib2-src/1.6.1/"

download \
  "v0.99.beta19.tar.gz" \
  "libcaca-0.99.beta19.tar.gz" \
  "2e1ed59dc3cb2f69d3d98fd0e6a205b4" \
  "https://github.com/cacalabs/libcaca/archive/"
#git clone https://github.com/cacalabs/libcaca.git "$BUILD_DIR"/libcaca-clone

download \
  "vo-amrwbenc-0.1.3.tar.gz" \
  "" \
  "f63bb92bde0b1583cb3cb344c12922e0" \
  "http://downloads.sourceforge.net/opencore-amr/vo-amrwbenc/"
#git clone https://github.com/mstorsjo/vo-amrwbenc.git "$BUILD_DIR"/vo-amrwbenc-clone

download \
  "opencore-amr-0.1.3.tar.gz" \
  "" \
  "09d2c5dfb43a9f6e9fec8b1ae678e725" \
  "http://downloads.sourceforge.net/opencore-amr/opencore-amr/"
#git clone https://github.com/BelledonneCommunications/opencore-amr.git "$BUILD_DIR"/opencore-amr-clone

download \
  "OpenSSL_1_0_2o.tar.gz" \
  "" \
  "5b5c050f83feaa0c784070637fac3af4" \
  "https://github.com/openssl/openssl/archive/"

download \
  "master.tar.gz" \
  "libilbc-master.tar.gz" \
  "nil" \
  "https://github.com/TimothyGu/libilbc/archive/"

download \
  "xvidcore-1.3.5.tar.gz" \
  "" \
  "69784ebd917413d8592688ae86d8185f" \
  "http://downloads.xvid.org/downloads/"

download \
  "x264-master.tar.gz" \
  "" \
  "nil" \
  "https://code.videolan.org/videolan/x264/-/archive/master/"

download \
  "x265_3.2.1.tar.gz" \
  "" \
  "94808045a34d88a857e5eaf3f68f4bca" \
  "https://bitbucket.org/multicoreware/x265/downloads/"

download \
  "v2.0.1.tar.gz" \
  "fdk-aac-2.0.1.tar.gz" \
  "5b85f858ee416a058574a1028a3e1b85" \
  "https://github.com/mstorsjo/fdk-aac/archive"

# libass dependency
download \
  "2.6.4.tar.gz" \
  "harfbuzz-2.6.4.tar.gz" \
  "188407981048daf6d92d554cfeeed48e" \
  "https://github.com/harfbuzz/harfbuzz/archive/"

download \
  "fribidi-1.0.8.tar.bz2" \
  "" \
  "962c7d8ebaa711d4e306161dbe14aa55" \
  "https://github.com/fribidi/fribidi/releases/download/v1.0.8/"

download \
  "0.14.0.tar.gz" \
  "libass-0.14.0.tar.gz" \
  "3c84884aa0589486bded10f71829bf39" \
  "https://github.com/libass/libass/archive/"

download \
  "lame-3.100.tar.gz" \
  "" \
  "83e260acbe4389b54fe08e0bdbf7cddb" \
  "http://downloads.sourceforge.net/project/lame/lame/3.100"

download \
  "twolame-0.3.13.tar.gz" \
  "" \
  "4113d8aa80194459b45b83d4dbde8ddb" \
  "https://netix.dl.sourceforge.net/project/twolame/twolame/0.3.13/"

download \
  "v1.3.1.tar.gz" \
  "opus-1.3.1.tar.gz" \
  "b27f67923ffcbc8efb4ce7f29cbe3faf" \
  "https://github.com/xiph/opus/archive/"

download \
  "v1.8.2.tar.gz" \
  "libvpx-v1.8.2.tar.gz" \
  "6dbccca688886c66a216d7e445525bce" \
  "https://github.com/webmproject/libvpx/archive/"
#git clone https://chromium.googlesource.com/webm/libvpx "$BUILD_DIR"/libvpx-clone

download \
  "rtmpdump-2.3.tgz" \
  "" \
  "eb961f31cd55f0acf5aad1a7b900ef59" \
  "https://rtmpdump.mplayerhq.hu/download/"

download \
  "soxr-0.1.3-Source.tar.xz" \
  "" \
  "3f16f4dcb35b471682d4321eda6f6c08" \
  "https://sourceforge.net/projects/soxr/files/"

download \
  "release-0.98b.tar.gz" \
  "vid.stab-release-0.98b.tar.gz" \
  "299b2f4ccd1b94c274f6d94ed4f1c5b8" \
  "https://github.com/georgmartius/vid.stab/archive/"

download \
  "release-2.9.2.tar.gz" \
  "zimg-release-2.9.2.tar.gz" \
  "a3755bff6207fcca5c06e7b1b408ce2e" \
  "https://github.com/sekrit-twc/zimg/archive/"

download \
  "v2.3.1.tar.gz" \
  "openjpeg-2.3.1.tar.gz" \
  "3b9941dc7a52f0376694adb15a72903f" \
  "https://github.com/uclouvain/openjpeg/archive/"

download \
  "v1.3.4.tar.gz" \
  "ogg-1.3.4.tar.gz" \
  "df1a9a95251a289aa5515b869db4b15f" \
  "https://github.com/xiph/ogg/archive/"

download \
  "v1.3.6.tar.gz" \
  "vorbis-1.3.6.tar.gz" \
  "03e967efb961f65a313459c5d0f4cbfb" \
  "https://github.com/xiph/vorbis/archive/"

download \
  "libtheora-1.1.1.tar.gz" \
  "" \
  "bb4dc37f0dc97db98333e7160bfbb52b" \
  "http://downloads.xiph.org/releases/theora/"

download \
  "Speex-1.2.0.tar.gz" \
  "Speex-1.2.0.tar.gz" \
  "4bec86331abef56129f9d1c994823f03" \
  "https://github.com/xiph/speex/archive/"

download \
  "n4.2.2.tar.gz" \
  "ffmpeg4.2.2.tar.gz" \
  "85c99f782dd3244a8e02ea85d29ecee2" \
  "https://github.com/FFmpeg/FFmpeg/archive"

[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

spd-say --rate -25 "Starting dependencies"

if [ $is_x86 -eq 1 ]; then
    echo
    /bin/echo -e "\e[93m*** Building yasm ***\e[39m"
    echo
    cd $BUILD_DIR/yasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

if [ $is_x86 -eq 1 ]; then
    echo
    /bin/echo -e "\e[93m*** Building nasm ***\e[39m"
    echo
    cd $BUILD_DIR/nasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

echo
/bin/echo -e "\e[93m*** Building zlib-1.2.5 (libPNG Dependency) ***\e[39m"
echo
cd $BUILD_DIR/zlib-1.2.5
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
fi
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libjpeg-turbo ***\e[39m"
echo
cd $BUILD_DIR/libjpeg-turbo-*
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$TARGET_DIR -DBUILD_SHARED_LIBS=0 -DCMAKE_INSTALL_LIBDIR=$TARGET_DIR/lib -DCMAKE_INSTALL_INCLUDEDIR=$TARGET_DIR/include
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libPNG ***\e[39m"
echo
cd $BUILD_DIR/libpng-*
./configure --prefix=$TARGET_DIR --libdir=$TARGET_DIR/lib --includedir=$TARGET_DIR/include CPPFLAGS=-I$TARGET_DIR/include
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building zlib-1.2.11 (Python Dependency) ***\e[39m"
echo
cd $BUILD_DIR/zlib-1.2.11
# Remove files from zlib-1.2.5 build
rm -f ../../target/include/zconf.h
rm -f ../../target/include/zlib.h
rm -f ../../target/lib/libz.*
rm -f ../../target/lib/pkgconfig/zlib.pc
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libzstd ***\e[39m"
echo
cd $BUILD_DIR/zstd-*
cd build/cmake
mkdir builddir
cd builddir
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DZSTD_LEGACY_SUPPORT=ON -DCMAKE_INSTALL_LIBDIR=$TARGET_DIR/lib -DZSTD_BUILD_SHARED:BOOL=OFF -DZSTD_LZMA_SUPPORT:BOOL=OFF -DZSTD_ZLIB_SUPPORT:BOOL=ON ..
#cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$TARGET_DIR -DBUILD_SHARED_LIBS=0 -DCMAKE_INSTALL_LIBDIR=$TARGET_DIR/lib -DCMAKE_INSTALL_INCLUDEDIR=$TARGET_DIR/include
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libwebp ***\e[39m"
echo
cd $BUILD_DIR/libwebp*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --enable-libwebpdecoder --enable-libwebpmux --enable-libwebpextras
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libTIFF ***\e[39m"
echo
cd $BUILD_DIR/tiff-*
./configure --prefix=$TARGET_DIR
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** ReBuilding libwebp ***\e[39m"
echo
cd $BUILD_DIR/libwebp*
make distclean
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared --enable-libwebpdecoder --enable-libwebpmux --enable-libwebpextras
make -j $jval
make install

#echo
#/bin/echo -e "\e[93m*** Building util-macros (xorgproto Dependency) ***\e[39m"
#echo
#cd $BUILD_DIR/util-macros-*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#./configure --prefix=$TARGET_DIR
#make install

#echo
#/bin/echo -e "\e[93m*** Building xorgproto (libXau Dependency) ***\e[39m"
#echo
#cd $BUILD_DIR/xorgproto-*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#mkdir build
#cd build/
#meson --prefix=$TARGET_DIR .. && ninja
#ninja install

echo
/bin/echo -e "\e[93m*** Building tcl (tkinter Dependency) ***\e[39m"
echo
cd $BUILD_DIR/tcl*/unix
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --enable-static
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building tkinter (Python Dependency) ***\e[39m"
echo
cd $BUILD_DIR/tk*/unix
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --with-tcl=$BUILD_DIR/tcl8.6.10/unix --enable-static
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libexpat (fontconfig Dependency) ***\e[39m"
echo
cd $BUILD_DIR/libexpat-*/expat
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./buildconf.sh
./configure --prefix=$TARGET_DIR --enable-static
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building Python 2.7 ***\e[39m"
echo
cd $BUILD_DIR/Python-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-shared --with-system-expat --with-system-ffi --with-ensurepip=yes --enable-unicode=ucs4
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libXML ***\e[39m"
echo
cd $BUILD_DIR/libxml*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-shared --with-history --with-python=$TARGET_DIR/bin/python3
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building FreeType2 (libass dependency) ***\e[39m"
echo
cd $BUILD_DIR/freetype*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg
sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-freetype-config --disable-shared
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building harfbuzz (libass dependency) ***\e[39m"
echo
cd $BUILD_DIR/harfbuzz-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" ./autogen.sh
PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-shared
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** ReBuilding FreeType2 after HarfBuzz ***\e[39m"
echo
cd $BUILD_DIR/freetype*
make install

echo
/bin/echo -e "\e[93m*** Building FontConfig ***\e[39m"
echo
cd $BUILD_DIR/fontconfig*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-shared
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building imlib2 (libcaca dependency)***\e[39m"
echo
cd $BUILD_DIR/imlib2-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-shared
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libcaca... ***\e[39m"
echo
cd $BUILD_DIR/libcaca-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
sed -i 's/"$amvers" "<" "1.5"/"$amvers" "<" "1.05"/g' ./bootstrap
./bootstrap
./configure --prefix=$TARGET_DIR --bindir="$BIN_DIR" --enable-static --disable-shared --disable-doc --disable-slang --disable-ruby --disable-csharp --disable-java --disable-cxx --disable-ncurses --disable-x11 #--disable-python --disable-cocoa
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building vo-amrwbenc... ***\e[39m"
echo
cd $BUILD_DIR/vo-amrwbenc-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --bindir="$BIN_DIR" --disable-shared --enable-static
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building opencore-amr... ***\e[39m"
echo
cd $BUILD_DIR/opencore-amr*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --bindir="$BIN_DIR" --disable-shared --enable-static
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building OpenSSL ***\e[39m"
echo
cd $BUILD_DIR/openssl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./config --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libilbc ***\e[39m"
echo
cd $BUILD_DIR/libilbc-*
sed 's/lib64/lib/g' -i CMakeLists.txt
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS=0
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building Xvid ***\e[39m"
echo
cd $BUILD_DIR/xvidcore/build/generic
sed -i 's/^LN_S=@LN_S@/& -f -v/' platform.inc.in
PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static
PATH="$BIN_DIR:$PATH" make -j $jval
make install
chmod -v 755 $TARGET_DIR/lib/libxvidcore.so.4.3
install -v -m755 -d $TARGET_DIR/share/doc/xvidcore-1.3.5/examples && install -v -m644 ../../doc/* $TARGET_DIR/share/doc/xvidcore-1.3.5 && install -v -m644 ../../examples/* $TARGET_DIR/share/doc/xvidcore-1.3.5/examples

echo
/bin/echo -e "\e[93m*** Building x264 ***\e[39m"
echo
cd $BUILD_DIR/x264*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-opencl --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building x265 ***\e[39m"
echo
cd $BUILD_DIR/x265*
cd build/linux
[ $rebuild -eq 1 ] && find . -mindepth 1 ! -name 'make-Makefiles.bash' -and ! -name 'multilib.sh' -exec rm -r {} +
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DENABLE_SHARED:BOOL=OFF -DSTATIC_LINK_CRT:BOOL=ON -DENABLE_CLI:BOOL=OFF ../../source
sed -i 's/-lgcc_s/-lgcc_eh/g' x265.pc
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building fdk-aac ***\e[39m"
echo
cd $BUILD_DIR/fdk-aac*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
autoreconf -fiv
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building fribidi (libass dependency)***\e[39m"
echo
cd $BUILD_DIR/fribidi-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libass ***\e[39m"
echo
cd $BUILD_DIR/libass-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" ./autogen.sh
PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-shared
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building mp3lame ***\e[39m"
echo
cd $BUILD_DIR/lame*
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-nasm --disable-shared $lame_build_target
make
make install

echo
/bin/echo -e "\e[93m*** Building libtwolame ***\e[39m"
echo
cd $BUILD_DIR/twolame-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --bindir="$BIN_DIR" --disable-shared --enable-static
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building opus ***\e[39m"
echo
cd $BUILD_DIR/opus*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo
/bin/echo -e "\e[93m*** Building libvpx ***\e[39m"
echo
cd $BUILD_DIR/libvpx*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-examples --disable-unit-tests --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building librtmp ***\e[39m"
echo
cd $BUILD_DIR/rtmpdump-*
cd librtmp
[ $rebuild -eq 1 ] && make distclean || true

# there's no configure, we have to edit Makefile directly
if [ "$platform" = "linux" ]; then
  sed -i "/INC=.*/d" ./Makefile # Remove INC if present from previous run.
  sed -i "s/prefix=.*/prefix=${TARGET_DIR_SED}\nINC=-I\$(prefix)\/include/" ./Makefile
  sed -i "s/SHARED=.*/SHARED=no/" ./Makefile
elif [ "$platform" = "darwin" ]; then
  sed -i "" "s/prefix=.*/prefix=${TARGET_DIR_SED}/" ./Makefile
fi
make install_base

echo
/bin/echo -e "\e[93m*** Building libsoxr ***\e[39m"
echo
cd $BUILD_DIR/soxr-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DWITH_OPENMP:bool=off -DBUILD_TESTS:bool=off
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libvidstab ***\e[39m"
echo
cd $BUILD_DIR/vid.stab-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  sed -i "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
elif [ "$platform" = "darwin" ]; then
  sed -i "" "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
fi
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR"
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building openjpeg ***\e[39m"
echo
cd $BUILD_DIR/openjpeg-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building zimg ***\e[39m"
echo
cd $BUILD_DIR/zimg-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --enable-static  --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libogg ***\e[39m"
echo
cd $BUILD_DIR/ogg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libvorbis ***\e[39m"
echo
cd $BUILD_DIR/vorbis*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo
/bin/echo -e "\e[93mCompiling libtheora...\e[39m"
echo
cd $BUILD_DIR/libtheora-*
sed -i 's/png_\(sizeof\)/\1/g' examples/png2theora.c
./configure --prefix=$TARGET_DIR --disable-oggtest --disable-vorbistest --with-ogg-includes="$TARGET_DIR/include" --with-ogg-libraries="$TARGET_DIR/build/lib" --with-vorbis-includes="$TARGET_DIR/include" --with-vorbis-libraries="$TARGET_DIR/build/lib" --disable-shared --enable-static
make -j $jval
make install

echo
/bin/echo -e "\e[93m*** Building libspeex ***\e[39m"
echo
cd $BUILD_DIR/speex*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

spd-say --rate -25 "Dependencies built"

# FFMpeg
echo
/bin/echo -e "\e[93m*** Building FFmpeg ***\e[39m"
date +%H:%M:%S
echo
cd $BUILD_DIR/FFmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true

if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="$TARGET_DIR/lib/pkgconfig" ./configure \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-version=Tec-2.8 \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-libs="-lpthread -lm -lz" \
    --extra-ldexeflags="-static" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-gpl \
    --enable-nonfree \
    --enable-version3 \
  --disable-alsa \
    --enable-bzlib \
  --disable-chromaprint \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-iconv \
    --enable-libass \
    --enable-libcaca \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libtwolame \
    --enable-libvidstab \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxcb \
    --enable-libxcb-shm \
    --enable-libxcb-xfixes \
    --enable-libxcb-shape \
    --enable-libxml2 \
    --enable-libxvid \
    --enable-libzimg \
  --disable-lzma \
    --enable-openssl \
  --disable-sndio \
  --disable-sdl2 \
  --disable-vaapi \
    --enable-vdpau \
  --disable-xlib \
    --enable-zlib
# Not working yet
#    
# Not tested yet
#    --enable-avresample \
#    --enable-libpulse \
# ---------------
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="${TARGET_DIR}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Cellar/openssl/1.0.2o_1/lib/pkgconfig" ./configure \
    --cc=/usr/bin/clang \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-version=Tec-2.8 \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-ldexeflags="-Bstatic" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl
fi

PATH="$BIN_DIR:$PATH" make -j $jval
make install
make distclean
date +%H:%M:%S
spd-say --rate -25 "Build Complete"
hash -r
