#!/bin/bash

################################################################
## This script will configure oracle11gR2 environment before  ##
## install.                                                   ##
## Require environment: CentOS 7.2                            ##
## Author: zzs                                                ##
## Date: 2016.11.20                                           ##
################################################################


## Check oracle environment
checkOracle=$(su - oracle -c 'sqlplus -v')
if [ -n "${checkOracle}" ]; then
      echo "Oracle has been installed!"
      exit
fi

## Save pwd
Present_Path=`pwd`

## Extract linux.x64_11gR2_database
ORACLE_BINARY_PATH="./"
oracle_file1="linux.x64_11gR2_database_1of2.zip"
oracle_file2="linux.x64_11gR2_database_2of2.zip"
unzip $ORACLE_BINARY_PATH/$oracle_file1
unzip $ORACLE_BINARY_PATH/$oracle_file2

## Install dependences for oracle database
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

grep "# Oracle configuration" /etc/sysctl.conf >> /dev/null
if [ $? -eq 0 ]; then
  echo "/etc/sysctl.conf has configured."
else
  echo "
# Oracle configuration
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
fi

/sbin/sysctl -p #(设置参数立即生效)

## configure security setting of oracle user
grep "# Oracle configuration" /etc/security/limits.conf >> /dev/null
if [ $? -eq 0 ]; then
      echo "/etc/security/limits.conf has configured."
else
      echo "# Oracle configuration" >> /etc/security/limits.conf
      echo "oracle    soft    nproc   2047" >> /etc/security/limits.conf
      echo "oracle    hard    nproc   16384" >> /etc/security/limits.conf
      echo "oracle    soft    nofile  1024" >> /etc/security/limits.conf
      echo "oracle    hard    nofile  65536" >> /etc/security/limits.conf
      echo "oracle    soft    stack   10240" >> /etc/security/limits.conf
fi

grep "# Oracle configuration" /etc/pam.d/login >> /dev/null
if [ $? -eq 0 ]; then
      echo "/etc/pam.d/login has configured."
else
      echo "# Oracle configuration" >> /etc/pam.d/login
      echo "session required /lib/security/pam_limits.so" >> /etc/pam.d/login
      echo "session    required     pam_limits.so" >> /etc/pam.d/login
fi

grep "# Oracle configuration" /etc/sysctl.conf >> /dev/null
if [ $? -eq 0 ]; then
      echo "/etc/profile has configured."
else
      echo "# Oracle configuration" >> /etc/profile
      echo "if [ $USER = "oracle" ]; then
if [ $SHELL = "/bin/ksh" ]; then
      ulimit -p 16384
      ulimit -n 65536
else
      ulimit -u 16384 -n 65536
fi
fi" >> /etc/profile
fi

source /etc/profile

# mkdir /etc/oratab
# mkidr /etc/oraInst.loc
# mkdir -p /u01/app/oracle/

## create install direction
mkdir -p /u01/app/
chown -R oracle:oinstall /u01/app/
chmod -R 775 /u01/app/

## create oraInst.loc config file and change file mode
if [ ! -f /etc/oraInst.loc ];then
      echo "nventory_loc=/u01/app/oracle/oraInventory" >> /etc/oraInst.loc
      echo "inst_group=oinstall" >> /etc/oraInst.loc
      chown oracle:oinstall /etc/oraInst.loc
      chmod 664 /etc/oraInst.loc
fi

## configure oracle user profile
grep "# Oracle configuration" /etc/sysctl.conf >> /dev/null
if [ $? -eq 0 ]; then
      echo "/etc/profile has configured."
else
      echo "# Oracle configuration" >> /home/oracle/.bash_profile
      echo "export ORACLE_BASE=/u01/app/oracle" >> /home/oracle/.bash_profile
      echo "export ORACLE_SID=orcl" >> /home/oracle/.bash_profile
fi

source /home/oracle/.bash_profile

## copy and configure response file.
cd /home/oracle
if [ -f /home/oracle/etc/db_install.rsp ]; then
      echo "db_install.rsp has been configured."
else
      mkdir etc
      cp /home/oracle/database/response/* /home/oracle/etc/
      chmod 700 /home/oracle/etc/*.rsp
      DB_INSTALL_PATH="/home/oracle/etc/db_install.rsp"
      sed -i "s/oracle.install.option=/oracle.install.option=INSTALL_DB_SWONLY/g" $DB_INSTALL_PATH
      sed -i "s/ORACLE_HOSTNAME=/ORACLE_HOSTNAME=db-system/g" $DB_INSTALL_PATH
      sed -i "s/UNIX_GROUP_NAME=/UNIX_GROUP_NAME=oinstall/g" $DB_INSTALL_PATH
      sed -i "s/INVENTORY_LOCATION=/INVENTORY_LOCATION=\/u01\/app\/oracle\/oraInventory/g" $DB_INSTALL_PATH
      sed -i "s/SELECTED_LANGUAGES=/SELECTED_LANGUAGES=en,zh_CN,zh_TW/g" $DB_INSTALL_PATH
      sed -i "s/ORACLE_HOME=/ORACLE_HOME=\/u01\/app\/oracle\/product\/11.2.0\/db_1/g" $DB_INSTALL_PATH
      sed -i "s/ORACLE_BASE=/ORACLE_BASE=\/u01\/app\/oracle/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.InstallEdition=/oracle.install.db.InstallEdition=EE/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.isCustomInstall=false/oracle.install.db.isCustomInstall=true/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.DBA_GROUP=/oracle.install.db.DBA_GROUP=dba/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.OPER_GROUP=/oracle.install.db.OPER_GROUP=oinstall/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.config.starterdb.type=/oracle.install.db.config.starterdb.type=GENERAL_PURPOSE/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.config.starterdb.globalDBName=/oracle.install.db.config.starterdb.globalDBName=orcl/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.config.starterdb.SID=/oracle.install.db.config.starterdb.SID=orcl/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.config.starterdb.memoryLimit=/oracle.install.db.config.starterdb.memoryLimit=512/g" $DB_INSTALL_PATH
      sed -i "s/oracle.install.db.config.starterdb.password.ALL=/oracle.install.db.config.starterdb.password.ALL=oracle/g" $DB_INSTALL_PATH
      sed -i "s/DECLINE_SECURITY_UPDATES=/DECLINE_SECURITY_UPDATES=true/g" $DB_INSTALL_PATH
      echo "db_install configure complete!"
fi

cd $Present_Path
echo "Oracle configure successful."