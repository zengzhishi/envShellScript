#!/bin/bash

################################################################
## This script will install oracle11gR2 database              ##
## for znsh as a system db.                                   ##
## Require environment: CentOS 7.2                            ##
## Author: zzs                                                ##
## Date: 2016.11.21                                           ##
################################################################

# ## user use this script as root
# source /home/oracle/.bash_profile


## Silent install oracle  use by oracle user
source /home/oracle/.bash_profile
su - oracle -c '/home/oracle/database/runInstaller -silent -force -responseFile /home/oracle/etc/db_install.rsp -ignorePrereq'

# ## back to root user
# logout
## use root user to configure
/u01/app/oracle/product/11.2.0/db_1/root.sh

## use oracle user
su - oracle
echo "export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
export PATH=${PATH}:/usr/bin:/bin:/usr/bin/X11:/usr/local/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$ORACLE_HOME/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$ORACLE_HOME/oracm/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/JRE
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/JRE/lib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/jlib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/rdbms/jlib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/network/jlib
export LIBPATH=${CLASSPATH}:$ORACLE_HOME/lib:$ORACLE_HOME/ctx/lib
export ORACLE_OWNER=oracle
export SPFILE_PATH=$ORACLE_HOME/dbs
export ORA_NLS10=$ORACLE_HOME/nls/data" >> /home/oracle/.bash_profile

source /home/oracle/.bash_profile

## Configure silent network
$ORACLE_HOME/bin/netca /silent /responseFile /home/oracle/etc/netca.rsp


##########################################
## ORACLE managers password             ##
## hostname: system-db                  ##
## sys: orcl                            ##
## system: orcl                         ##
##########################################
## Configure slient db
HOST_FIELD="system-db"

sed -i "s/GDBNAME = \"orcl11g.us.oracle.com\"/GDBNAME=\"orcl.$HOST_FIELD\"/g" /home/oracle/etc/dbca.rsp
sed -i "s/SID = \"orcl11g\"/SID=\"orcl\"/g" /home/oracle/etc/dbca.rsp

sed -i "s/#SYSPASSWORD = \"password\"/#SYSPASSWORD = \"orcl\"/g" /home/oracle/etc/dbca.rsp
sed -i "s/#SYSTEMPASSWORD = \"password\"/#SYSTEMPASSWORD = \"orcl\"/g" /home/oracle/etc/dbca.rsp

$ORACLE_HOME/bin/dbca -silent -responseFile /home/oracle/etc/dbca.rsp

## check status
lsnrctl status

## back to root user
logout
echo "Install oracle complete!"
exit