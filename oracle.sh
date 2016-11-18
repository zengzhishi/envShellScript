#!/bin/bash
#Oracle 11g
####################################################################################
#To determine the distribution and version of Linux installed.
cat /proc/version
#To determine whether the required kernel is installed.
uname -r
#On Linux x86-64
# At least 4 GB of RAM
    grep MemTotal /proc/meinfo
#To determine the size of the configured swap space,enter the following command:
  grep SwapTotal /proc/meminfo
####################################################################################
#Checking the Software Requirements
####################################################################################
#Package Requirements
rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' binutils \
compat-libstdc++-33 \
elfutils-libelf \
elfutils-libelf-devel \
gcc \
gcc-c++ \
glibc \
glibc-common \
glibc-devel \
glibc-headers \
ksh \
libaio \
libaio-devel \
libgcc \
libstdc++ \
libstdc++-devel \
make \
sysstat \
unixODBC \
unixODBC-devel
#yum install unixODBC
#yum install unixODBC-devel
####################################################################################
#To determine if the Oracle Inventory group exit
grep oinstall /etc/group
#To determine whether the oraInstall.loc file exists.
cat /etc/oraInst.loc
####################################################################################