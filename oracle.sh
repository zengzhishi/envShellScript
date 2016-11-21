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

##### install essential dependance #######
yum install -y binutils \
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



DATE=`date +%Y+%m+%d`
mkdir /bak
#Creating Required Operating System Groups and Users
groupadd -g 507 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
groupadd -g 504 asmadmin
groupadd -g 505 asmoper
groupadd -g 506 asmdba
useradd -g oinstall -G dba,asmdba,oper -d /home/oracle oracle
useradd -g oinstall -G asmadmin,asmdba,asmoper,oper,dba grid
id oracle
id grid
passwd oracle
passwd grid
######################################
mkdir -p /u01/app/grid
mkdir -p /u01/app/crs_base
mkdir -p /u01/app/crs_home
mkdir -p /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01/app/oracle
chown -R grid:oinstall /u01/app/crs*
chown -R grid:oinstall /u01/app/grid
mkdir -p /u01/app/oraInventory
chown -R grid:oinstall /u01/app/oraInventory
chmod -R 775 /u01/
ls -al /u01
######################################
#CheckResource Limits for the Oracle Software Installation Users
yes|cp /etc/security/limits.conf /bak/bak_limits.conf
#Installation Owner Resource Limit Recommended Ranges
echo "#xcl "${DATE} >> /etc/security/limits.conf
echo "oracle soft nproc 2047" >> /etc/security/limits.conf
echo "oracle hard nproc 16384" >> /etc/security/limits.conf
echo "oracle soft nofile 1024" >> /etc/security/limits.conf
echo "oracle hard nofile 65536" >> /etc/security/limits.conf
###########
#aio
yes|cp /proc/sys/fs/aio-max-nr /bak/aio-max-nr
echo > /proc/sys/fs/aio-max-nr 1048576
###########
#Configuring Kernel Parameters for Linux
yes|cp /etc/sysctl.conf /bak/sysctl.conf
echo " ########### " >> /etc/sysctl.conf
echo "#xcl "${DATE} >> /etc/sysctl.conf
echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf
echo "fs.file-max = 6815744" >> /etc/sysctl.conf
echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
echo "kernel.shmmax = 536870912" >> /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 1024 65000" >> /etc/sysctl.conf
echo "net.core.rmem_default=262144" >> /etc/sysctl.conf
echo "net.core.rmem_max=262144" >> /etc/sysctl.conf
echo "net.core.wmem_default=262144" >> /etc/sysctl.conf
echo "net.core.wmem_max=262144" >> /etc/sysctl.conf
/sbin/sysctl -p
###########
cp /etc/pam.d/login /bak/login
#64bit
echo "#xcl "${DATE} >> /etc/pam.d/login
echo "session required /lib/security/pam_limits.so" >> /etc/pam.d/login
echo "session required pam_limits.so" >> /etc/pam.d/login

########################################################################################
# Add host
echo ${OracleServerIp}" "${OracleServerName} >> /etc/hosts
echo "HOSTNAME="${OracleServerName} > /etc/sysconfig/network

#禁用网络时间服务
systemctl stop ntpd
systemctl disable ntpd.service

#永久关闭防火墙
sed 

systemctl stop iptables
systemctl disable iptables


# #环境回滚
# ######################################
# yes|cp /bak/bak_limits.conf /etc/security/limits.conf
# yes|cp /bak/aio-max-nr /proc/sys/fs/aio-max-nr
# yes|cp /bak/sysctl.conf /etc/sysctl.conf
# /sbin/sysctl -p
# yes|cp /bak/login /etc/pam.d/login
# ######################################
# userdel oinstall
# userdel dba
# userdel oper
# userdel asmadmin
# userdel asmoper
# userdel asmdba
# groupdel dba
# groupdel oper
# groupdel asmadmin
# groupdel asmoper
# groupdel asmdba
# ######################################





############################
DATE=`date +%Y-%m-%d`
env_etc_profile="/etc/profile"
env_profile="/home/oracle/.bash_profile"
######################################
env_ORACLE_HOSTNAME="erpdbserver"
env_ORACLE_OWNER="oracle"
env_ORACLE_BASE="/u01/app/oracle"
env_ORACLE_HOME="/product/11.2.0/db_1"
env_ORACLE_UNQNAME="xcldb"
env_ORACLE_SID="xcldb"
#AMERICAN_AMERICA.AL32UTF8
env_NLS_LANG="AMMERICAN_AMERICA.ZHS16GBK"
######################################
yes|cp ${env_etc_profile} ${env_etc_profile}"_bak"
yes|cp ${env_profile} ${env_profile}"_bak"
######################################
echo " " >> ${env_etc_profile}
echo "###########################" >> ${env_etc_profile}
echo "###xcl "${DATE} >> ${env_etc_profile}
echo "if [ \$USER = \"oracle\" ]; then" >> ${env_etc_profile}
echo " if [ \$SHELL = \"/bin/ksh\" ]; then" >> ${env_etc_profile}
echo " ulimit -p 16384" >> ${env_etc_profile}
echo " ulimit -n 65536" >> ${env_etc_profile}
echo " else" >> ${env_etc_profile}
echo " ulimit -u 16384 -n 65536" >> ${env_etc_profile}
echo " fi" >> ${env_etc_profile}
echo "fi" >> ${env_etc_profile}
echo "###########################" >> ${env_etc_profile}
######################################
echo "###########################" >> ${env_profile}
echo "###xcl "${DATE} >> ${env_profile}
echo "TMP=/tmp" >> ${env_profile}
echo "TMPDIR=\$TMP" >> ${env_profile}
echo "export TMP TMPDIR" >> ${env_profile}
echo " " >> ${env_profile}
#export ORACLE_HOSTNAME="${env_ORACLE_HOSTNAME} >> ${env_profile}
echo "ORACLE_OWNER="${env_ORACLE_OWNER} >> ${env_profile}
echo "ORACLE_BASE="${env_ORACLE_BASE} >> ${env_profile}
echo "ORACLE_HOME=\$ORACLE_BASE"${env_ORACLE_HOME} >> ${env_profile}
echo "ORACLE_UNQNAME="${env_ORACLE_UNQNAME} >> ${env_profile}
echo "ORACLE_SID="${env_ORACLE_SID} >> ${env_profile}
echo "export ORACLE_OWNER ORACLE_BASE ORACLE_HOME ORACLE_UNQNAME ORACLE_SID" >> ${env_profile}
echo " " >> ${env_profile}
echo "CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib" >> ${env_profile}
echo "LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib:/usr/local/lib" >> ${env_profile}
echo "export CLASSPATH LD_LIBRARY_PATH" >> ${env_profile}
echo " " >> ${env_profile}
echo "ORACLE_TERM=xterm" >> ${env_profile}
#export ORACLE_TERM=vt100
echo "NLS_LANG="${env_NLS_LANG} >> ${env_profile}
echo "TNS_ADMIN=\$ORACLE_HOME/network/admin" >> ${env_profile}
#echo "SQLPATH=~/mydba/sql:\$ORACLE_HOME/sqlplus/admin" >> ${env_profile}
#echo "export ORACLE_TERM NLS_LANG TNS_ADMIN SQLPATH" >> ${env_profile}
echo "export ORACLE_TERM NLS_LANG TNS_ADMIN " >> ${env_profile}
echo " " >> ${env_profile}
echo "PATH=\$ORACLE_HOME/bin:/usr/local/bin:/bin:/usr/sbin:/usr/bin:\$PATH" >> ${env_profile}
echo "export PATH" >> ${env_profile}
echo " " >> ${env_profile}
#echo "PS1='\`whoami\`@\`hostname -s\`' [\$PWD]" >> ${env_profile}
#echo "export PS1" >> ${env_profile}
echo "PS1='[\`whoami\`@\`hostname -s\`] :'" >> ${env_profile}
echo " " >> ${env_profile}
echo "umask 022" >> ${env_profile}
echo "###########################" >> ${env_profile}
echo ""




# install oracle 
################################################################################
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=xclora.localdomain
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en,zh_CN,zh_TW
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.isCustomInstall=true
oracle.install.db.customComponents=oracle.rdbms.partitioning:11.2.0.1.0,oracle.rdbms.dm:11.2.0.1.0
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true



./runInstaller -silent -ignoreSysPrereqs -force -ignorePrereq -responseFile /home/oracle/oracle_install.rsp