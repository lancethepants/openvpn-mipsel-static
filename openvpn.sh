#!/bin/bash

set -e
set -x

mkdir ~/openvpn && cd ~/openvpn

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
DEST=$BASE/jffs
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections"	
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=/jffs --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET http://zlib.net/zlib-1.2.8.tar.gz
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--prefix=/jffs

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

mkdir -p $SRC/openssl && cd $SRC/openssl
$WGET https://www.openssl.org/source/openssl-1.0.2d.tar.gz
tar zxvf openssl-1.0.2d.tar.gz
cd openssl-1.0.2d

./Configure linux-mips32 \
-mtune=mips32 -mips32 -ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=/opts zlib \
--with-zlib-lib=$DEST/lib \
--with-zlib-include=$DEST/include

make CC=mipsel-linux-gcc
make CC=mipsel-linux-gcc install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

######## ####################################################################
# LZO2 # ####################################################################
######## ####################################################################

mkdir $SRC/lzo2 && cd $SRC/lzo2
$WGET http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz
tar zxvf lzo-2.09.tar.gz
cd lzo-2.09

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENVPN # #################################################################
########### #################################################################

mkdir $SRC/openvpn && cd $SRC/openvpn
$WGET http://swupdate.openvpn.org/community/releases/openvpn-2.3.8.tar.gz
tar zxvf openvpn-2.3.8.tar.gz
cd openvpn-2.3.8

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--disable-plugin-auth-pam \
--enable-password-save

$MAKE LIBS="-all-static -lssl -lcrypto -lz -llzo2"
make install DESTDIR=$BASE/openvpn
