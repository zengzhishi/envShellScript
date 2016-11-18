#!/bin/bash

# Simple script to install MariaDB on ubuntu only 64bit
# By PhongLe - http://congdonglinux.vn
source config.sh

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

## Install MariaDB
apt-get install -y mariadb-server

mysqladmin -u root password "$rootmysqlpwd"

## Xoa cac user rong va database test
mysql -u root -p"$rootmysqlpwd" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost')"
mysql -u root -p"$rootmysqlpwd" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$rootmysqlpwd" -e "DROP DATABASE test"
mysql -u root -p"$rootmysqlpwd" -e "FLUSH PRIVILEGES"

clear
echo -e "\n\n\n";
echo "Thank you for use scripts ===  Install MariaDB  Successfully ";
echo " Password root access mysql: $rootmysqlpwd "; 
