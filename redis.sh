#!/bin/bash

################################################################
## This script will configure redis environment.              ##
## Require environment: CentOS 7.2                            ##
## Author: zzs                                                ##
## Date: 2016.11.20                                           ##
################################################################

REDIS_VERSION="3.2.5"
PAKAGE_SUFFIX=".tar.gz"

## Checking installed stats
redis-cli -v >> /dev/null
if [ $? -eq 0 ]; then
    echo "Redis has been installed"
    exit
fi

## Save pwd
Present_Path=`pwd`

## Check redis pakages, if isn't exist, get from web.
if [ ! -f ./pakages/redis-${REDIS_VERSION}${PAKAGE_SUFFIX} ]; then
    # Get redis from web
    wget http://download.redis.io/releases/redis-${REDIS_VERSION}${PAKAGE_SUFFIX}
    tar -zxvf redis-${REDIS_VERSION}${PAKAGE_SUFFIX}
else
    tar -zxvf ./pakages/redis-${REDIS_VERSION}${PAKAGE_SUFFIX}
fi

## Install redis
cd redis-${REDIS_VERSION}
make
cd src && make install

## Redis configuration
mkdir -p /usr/local/redis/bin
mkdir -p /usr/local/redis/etc

mv ../../redis-${REDIS_VERSION}/redis.conf /usr/local/redis/etc
cd ../../redis-${REDIS_VERSION}/src
mv mkreleasehdr.sh redis-benchmark redis-check-aof redis-check-dump redis-cli redis-server /usr/local/redis/bin

## Set redis to be daemo process
sed -i "s/daemonize no/daemonize yes/g" /usr/local/redis/etc/redis.conf
redis-server /usr/local/redis/etc/redis.conf

cd ${Present_Path}
echo "Redis install complete."
exit