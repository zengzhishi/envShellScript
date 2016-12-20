# Environment configure shell script

1. `mysql.sh` was imitated from [congdonglinux](https://github.com/congdonglinux "congdonglinux")
2. `oracle_config.sh` and `oracle_ins.sh` was imitated from [oracle11G静默安装过程——linux环境](http://www.2cto.com/database/201307/229218.html "oracle11G静默安装过程——linux环境")
    
    * `oracle_config.sh` will set preconfiguration for oracle environment install.
    * `oracle_ins.sh` will install oracle database.
    
3. `basic_environment.sh` will instll jdk and tomcat environment.
4. `postgresql.sh` install postgresql database by yum.


Please exec java_env.sh using:


        # source ./java_env.sh
        or
        # . ./java_env.sh