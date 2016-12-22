#!/bin/bash

################################################################
## This script will install nginx for znsh                    ##
## Author: zzs                                                ##
## Date: 2016.12.20                                           ##
################################################################

# Basic configuration
VERSION="1.10.2"
NGINX_VERSION="nginx-${VERSION}"
PCRE_VERSION="pcre-8.39"
ZLIB_VERSION="zlib-1.2.8"
SSL_VERSION="openssl-1.1.0c"
gz_suffix=".tar.gz"
NGINX_PATH="/usr/local/nginx"

# Pakages web resource
nginx_url="http://nginx.org/download/${NGINX_VERSION}${gz_suffix}"
openssl_url="https://www.openssl.org/source/${SSL_VERSION}${gz_suffix}"
zlib_url="http://zlib.net/${ZLIB_VERSION}${gz_suffix}"
pcre_url="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_VERSION}${gz_suffix}"


## Checking environment
if

# Get pakages from web
wget -P ./pakages $nginx_url
wget -P ./pakages $pcre_url
wget -P ./pakages $zlib_url
wget -P ./pakages $openssl_url


# Unpakage these pakages
cd ./pakages
tar -zxvf ${NGINX_VERSION}${gz_suffix}
tar -zxvf ${SSL_VERSION}${gz_suffix}
tar -zxvf ${ZLIB_VERSION}${gz_suffix}
tar -zxvf ${NGINX_VERSION}${gz_suffix}
# Get vts module
git clone git://github.com/vozlt/nginx-module-vts.git

# Compile nginx
nginx_dir=${NGINX_VERSION}
openssl_dir=${SSL_VERSION}
zlib_dir=${ZLIB_VERSION}
pcre_dir=${PCRE_VERSION}
cd $nginx_dir
./configure \
    --sbin-path=${NGINX_PATH}/sbin/nginx \
    --conf-path=${NGINX_PATH}/conf/nginx.conf \
    --pid-path=${NGINX_PATH}/nginx.pid \
    --with-http_ssl_module
    --with-openssl=../${openssl_dir}
    --with-pcre=../${pcre_dir}
    --with-zlib=../${zlib_dir}
    --add-module=../nginx-module-vts
# install nginx
make && make install