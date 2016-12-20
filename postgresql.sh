#!/bin/bash
################################################################
## This script will install postgresql.                       ##
## Require environment: CentOS 7.2                            ##
## Author: zzs                                                ##
## Date: 2016.11.19                                           ##
################################################################

source config.sh

# Get postgresql96
wget https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/postgresql96-libs-9.6.1-1PGDG.rhel7.x86_64.rpm
wget https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/postgresql96-9.6.1-1PGDG.rhel7.x86_64.rpm
wget https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/postgresql96-server-9.6.1-1PGDG.rhel7.x86_64.rpm
wget https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/postgresql96-contrib-9.6.1-1PGDG.rhel7.x86_64.rpm


# Install postgresql96
rpm -ivh postgresql96-libs-9.6.1-1PGDG.rhel7.x86_64.rpm
rpm -ivh postgresql96-9.6.1-1PGDG.rhel7.x86_64.rpm
rpm -ivh postgresql96-server-9.6.1-1PGDG.rhel7.x86_64.rpm
yum install -y libxslt.x86_64
rpm -ivh postgresql96-contrib-9.6.1-1PGDG.rhel7.x86_64.rpm

# Initial the postgresql96 初始化数据库
/usr/pgsql-9.6/bin/postgresql96-setup initdb

# enable start service when domain start up
systemctl enable postgresql-9.6.service
systemctl start postgresql-9.6.service


export POSTGRESPATH=/usr/pgsql-9.6/bin
export POSTGRESQLPWD='znsh417'
su - postgres -c 'psql -U postgres --command ALTER USER postgres WITH PASSWORD '${POSTGRESQLPWD}';'