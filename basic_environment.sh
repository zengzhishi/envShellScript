#!/bin/bash

################################################################
## This script will install oracle-jdk8u112 and tomcat8.0.38  ##
## for znsh as a basic environment.                           ##
## Author: zzs                                                ##
## Date: 2016.11.22                                           ##
################################################################

JDK_VERSION="jdk-8u112-linux"
JDK_Direction="jdk1.8.0_112"
X64Bit_Type="x64"
X86Bit_Type="i586"
gz_suffix=".tar.gz"
rpm_suffix=".rpm"


################################################################
## Install oracle jdk environment                             ##
################################################################
fucntion jdkInstall()
{
    ## Check computor bit type
    BIT=${getconf LONG_BIT}
    if [ $BIT -eq 64]; then
        BitType=${X64Bit_Type}
    else
        BitType=${X86Bit_Type}
    fi

    ## Check install pakage type.
    pakages=$(ls ./pakages/$JDK_VERSION)
    for file in pakages
    do
        if [ ${JDK_VERSION}-${BitType}${gz_suffix} = ${file} ]
        then
            # install jdk environment by achieve package
            tar -zxvf ${file}
            mkdir -p /usr/local/jdk
            mv ${JDK_Direction} /usr/local/jdk
            ln -s /usr/local/jdk/jdk1.8.0_112 /usr/local/jdk/jdk
            echo ""
            echo "# oracle jdk environment" >> /etc/profile
            echo "export JAVA_HOME=/usr/local/jdk/jdk" >> /etc/profile
            echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
            echo "export CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> /etc/profile
            source /etc/profile
            echo "Install successfully!"
            return
        else if [ ${JDK_VERSION}-${BitType}${rpm_suffix} = ${file} ]
        then 
            # install jdk environment by rpm
            rpm -ivh ${JDK_VERSION}-${BitType}.${rpm_suffix}
            echo "Install successfully!"        
            return
        fi
    done
    echo "No accessible jdk install pakage"
    exit

}




## Check jdk environment
echo "Checking JDK environment..."
checkResult=${rpm -qa | grep java}
if [ ! -n checkResult ]; then
    echo "Java environment has been exist!"
else 
    jdkInstall
fi
echo "Jdk environment install complete!"

## Check tomcat environment
echo "Checking tomcat environment..."


