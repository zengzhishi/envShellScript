#!/bin/bash

Present_Path=`pwd`

ORACLE_BINARY_PATH="./"
oracle_file1="linux.x64_11gR2_database_1of2.zip"
oracle_file2="linux.x64_11gR2_database_2of2.zip"
unzip $ORACLE_BINARY_PATH/$oracle_file1
unzip $ORACLE_BINARY_PATH/$oracle_file2

## install dependences
yum install -y \
binutils \
compat-libstdc++-33 \
elfutils-libelf \
elfutils-libelf-devel \
expat \
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

## create user and group
/usr/sbin/groupadd oinstall #(建立产品清单管理组)
/usr/sbin/groupadd dba #(建立数据库安装组)
# /usr/sbin/groupadd asmadmin #(建立ASM管理组)
# /usr/sbin/groupadd asmdba #(建立Grid管理组)
/usr/sbin/useradd -g oinstall -G dba -m oracle -s /bin/bash

mv ${ORACLE_BINARY_PATH}/database /home/oracle

# ## save uid and gid for user oracle
# uid=`id oracle|awk '{print $1}'|cut -d '=' -f 2|cut -d '(' -f 1`
# gid=`id oracle|awk '{print $2}'|cut -d '=' -f 2|cut -d '(' -f 1`

## comfigure sysctl config file.
echo "
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
" >> /etc/sysctl.conf

/sbin/sysctl -p #(设置参数立即生效)

## configure security setting of oracle user
echo "oracle    soft    nproc   2047" >> /etc/security/limits.conf
echo "oracle    hard    nproc   16384" >> /etc/security/limits.conf
echo "oracle    soft    nofile  1024" >> /etc/security/limits.conf
echo "oracle    hard    nofile  65536" >> /etc/security/limits.conf
echo "oracle    soft    stack   10240" >> /etc/security/limits.conf

echo "session required /lib/security/pam_limits.so" >> /etc/pam.d/login
echo "session    required     pam_limits.so" >> /etc/pam.d/login

echo "if [ $USER = "oracle" ]; then
        if [ $SHELL = "/bin/ksh" ]; then
              ulimit -p 16384
              ulimit -n 65536
        else
              ulimit -u 16384 -n 65536
        fi
fi" >> /etc/profile

source /etc/profile

# mkdir /etc/oratab
# mkidr /etc/oraInst.loc
# mkdir -p /u01/app/oracle/

## create install direction
mkdir -p /u01/app/
chown -R oracle:oinstall /u01/app/
chmod -R 775 /u01/app/

if [ ! -f /etc/oraInst.loc ];then
    echo "nventory_loc=/u01/app/oracle/oraInventory 
      inst_group=oinstall" >> /etc/oraInst.loc
fi

chown oracle:oinstall /etc/oraInst.loc
chmod 664 /etc/oraInst.loc

## configure oracle user profile
echo "export ORACLE_BASE=/u01/app/oracle" >> /home/oracle/.bash_profile
echo "export ORACLE_SID=orcl" >> /home/oracle/.bash_profile

source /home/oracle/.bash_profile

## copy and configure response file.
cd /home/oracle
mkdir etc
cp /home/oracle/database/response/* /home/oracle/etc/
chmod 700 /home/oracle/etc/*.rsp

sed -i "s/oracle.install.option=/oracle.install.option=INSTALL_DB_SWONLY/g" /home/oracle/etc/db_install.rsp
sed -i "s/ORACLE_HOSTNAME=/ORACLE_HOSTNAME=java-linux-test/g" /home/oracle/etc/db_install.rsp
sed -i "s/UNIX_GROUP_NAME=/UNIX_GROUP_NAME=oinstall/g" /home/oracle/etc/db_install.rsp
sed -i "s/INVENTORY_LOCATION=/INVENTORY_LOCATION=\/u01\/app\/oracle\/oraInventory/g" /home/oracle/etc/db_install.rsp
sed -i "s/SELECTED_LANGUAGES=/SELECTED_LANGUAGES=en,zh_CN,zh_TW/g" /home/oracle/etc/db_install.rsp
sed -i "s/ORACLE_HOME=/ORACLE_HOME=\/u01\/app\/oracle\/product\/11.2.0\/db_1/g" /home/oracle/etc/db_install.rsp
sed -i "s/ORACLE_BASE=/ORACLE_BASE=\/u01\/app\/oracle/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.InstallEdition=/oracle.install.db.InstallEdition=EE/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.isCustomInstall=false/oracle.install.db.isCustomInstall=true/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.DBA_GROUP=/oracle.install.db.DBA_GROUP=dba/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.OPER_GROUP=/oracle.install.db.OPER_GROUP=oinstall/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.config.starterdb.type=/oracle.install.db.config.starterdb.type=GENERAL_PURPOSE/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.config.starterdb.globalDBName=/oracle.install.db.config.starterdb.globalDBName=orcl/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.config.starterdb.SID=/oracle.install.db.config.starterdb.SID=orcl/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.config.starterdb.memoryLimit=/oracle.install.db.config.starterdb.memoryLimit=512/g" /home/oracle/etc/db_install.rsp
sed -i "s/oracle.install.db.config.starterdb.password.ALL=/oracle.install.db.config.starterdb.password.ALL=oracle/g" /home/oracle/etc/db_install.rsp
sed -i "s/DECLINE_SECURITY_UPDATES=/DECLINE_SECURITY_UPDATES=true/g" /home/oracle/etc/db_install.rsp

cd $Present_Path
echo "Oracle configure successful."