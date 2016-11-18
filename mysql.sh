#!/bin/bash

# Simple script to install MariaDB on  6.x only 64bit
# By PhongLe - http://congdonglinux.vn

## Check info
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
ram=$( free -m | awk 'NR==2 {print $2}' )
buff_pool_size=$(echo "$ram/10*6"|bc)
log_file_size=$(echo "$ram/16*2"|bc) 
innodb_thread_concurrency=$(echo "$cpucores*2"|bc)
innodb_read_io_threads=$(echo "$cpucores*4"|bc)
innodb_write_io_threads=$(echo "$cpucores*4"|bc)

cat >> "/etc/sysctl.conf" <<END
vm.swappiness = 0
END
sysctl -p 

##Create Repo MariaDB
cat >> "/etc/yum.repos.d/MariaDB.repo" <<END
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
END

## Install MariaDB
yum -y install MariaDB-server MariaDB-client
touch /var/log/mysql_slow.log
chown mysql:mysql /var/log/mysql_slow.log


cat > "/etc/my.cnf" <<END
[client]
port            = 3306
socket          = /var/lib/mysql/mysql.sock
[mysqld]
ft_min_word_len = 3
##GENERAL
user = mysql
port = 3306
default_storage_engine = InnoDB
socket = /var/lib/mysql/mysql.sock
pid_file = /var/lib/mysql/mysql.pid
collation-server = utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server = utf8
##DATA STORAGE
datadir=/var/lib/mysql
##Logging
log-error = /var/log/mysql-err.log
slow-query-log-file = /var/log/mysql_slow.log
slow_query_log = 1
#general_log = 1
#general_log_file = /var/log/mysql_general.log
binlog_format = MIXED
log-queries-not-using-indexes
long_query_time = 1
expire_logs_days = 4
log-bin=mysql-bin
##MyISAM
key_buffer_size = 256M
### CACHES AND LIMITS #
max_allowed_packet = 128M
sort_buffer_size = 2M
join_buffer_size = 4M
read_buffer_size = 2M
read_rnd_buffer_size = 4M
thread_cache_size = 16
query_cache_size= 128M
query_cache_limit = 16M
query_cache_type = 1
thread_concurrency = 16
back_log = 1024
connect_timeout = 200
interactive_timeout = 300
tmp_table_size = 64M
max_heap_table_size = 64M
table_open_cache = 2000
open_files_limit = 65535
wait_timeout = 200
##Safety
skip-name-resolve
skip-external-locking
max_connections = 800
max_user_connections = 700
max_connect_errors = 1000000
local-infile=0
##InnoDB
innodb_buffer_pool_size = $buff_pool_size
innodb_additional_mem_pool_size = 20M
innodb_log_file_size = $log_file_size
innodb_log_buffer_size = 128M
innodb_flush_log_at_trx_commit = 2
innodb_thread_concurrency = $innodb_thread_concurrency
innodb_flush_method=O_DIRECT
innodb_lock_wait_timeout=120
innodb_file_per_table
innodb_io_capacity=500
innodb_read_io_threads = $innodb_read_io_threads
innodb_write_io_threads = $innodb_write_io_threads
##add new
#innodb_io_capacity=2000
#innodb_io_capacity_max=6000
#innodb_lru_scan_depth=2000
#innodb_lock_wait_timeout = 7200
[mysqldump]
#quick
#max_allowed_packet = 16M
[mysqlhotcopy]
interactive-timeout
END

##Tao password cho tai khoan root mysql
printf "\nNhap vao password root mysql ban muon dat [ENTER]: "
read rootmysql
##Tao password random cho tai khoan root
##root_password=`date |md5sum |cut -c '14-30'`

rm -f /var/lib/mysql/ib_logfile0
rm -f /var/lib/mysql/ib_logfile1
rm -f /var/lib/mysql/ibdata1

## Start all service
/etc/init.d/mysql start
chkconfig mysql on

mysqladmin -u root password "$rootmysql"

## Xoa cac user rong va database test
mysql -u root -p"$rootmysql" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost')"
mysql -u root -p"$rootmysql" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$rootmysql" -e "DROP DATABASE test"
mysql -u root -p"$rootmysql" -e "FLUSH PRIVILEGES"

clear
echo -e "\n\n\n";
echo "Thank you for use scripts ===  Install MariaDB  Successfully ";
echo " Password root access mysql: $rootmysql "; 
