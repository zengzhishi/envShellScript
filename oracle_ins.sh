#!/bin/bash

## Silent install oracle 
cd /home/oracle/database
source /home/oracle/.bash_profile
./runInstaller -silent -force -responseFile /home/oracle/etc/db_install.rsp

## 
/u01/app/oracle/product/11.2.0/db_1/root.sh

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

## Configure slient db
sed -i "s/GDBNAME=/GDBNAME=\"orcl.java-linux-test\"/g" /home/oracle/etc/dbca.rsp
sed -i "s/SID = \"orcl11g\"/SID=\"orcl\"/g" /home/oracle/etc/dbca.rsp
sed -i "s/#CHARACTERSET = \"US7ASCII\"/CHARACTERSET=\"AL32UTF8\"/g" /home/oracle/etc/dbca.rsp
sed -i "s/#NATIONALCHARACTERSET= \"UTF8\"/NATIONALCHARACTERSET=\"UTF8\"/g" /home/oracle/etc/dbca.rsp

$ORACLE_HOME/bin/dbca -silent -responseFile /home/oracle/dbca.rsp

