#!/bin/bash

################################################################
## This script will install oracle-jdk8u112                   ##
## for znsh as a basic environment.                           ##
## Author: zzs                                                ##
## Date: 2016.12.20                                           ##
################################################################


JDK_VERSION="jdk-8u112-linux"
JDK_Direction="jdk1.8.0_112"
X64Bit_Type="x64"
X86Bit_Type="i586"
gz_suffix=".tar.gz"
rpm_suffix=".rpm"
zip_suffix=".zip"


################################################################
## Install oracle jdk environment                             ##
## It has two type of install pakages: .tar.gz, .rpm          ##
################################################################

jdkInstall()
{
    BitType=$1
    ## Check install pakage type.
    pakages=$(ls ./pakages/$JDK_VERSION*)
    for file in ${pakages}
    do
        fileName=$(echo $file | cut -d '/' -f 3)
        if [ ${JDK_VERSION}-${BitType}${gz_suffix} = ${fileName} ]
        then
            # install jdk environment by achieve package
            tar -zxvf ${file}
            mkdir -p /usr/local/jdk
            mv ${JDK_Direction} /usr/local/jdk
            ln -s /usr/local/jdk/jdk1.8.0_112 /usr/local/jdk/jdk
            echo "" >> /etc/profile
            echo "# oracle jdk environment" >> /etc/profile
            echo "export JAVA_HOME=/usr/local/jdk/jdk" >> /etc/profile
            echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
            echo "export CLASS_PATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
            source /etc/profile
            java -version
            echo "Install successfully!"
            echo "If java exec file not in the path, please use command:"
            echo "      # source /etc/profile"
            return
        elif [ ${JDK_VERSION}-${BitType}${rpm_suffix} = ${fileName} ]
        then 
            # install jdk environment by rpm
            rpm -ivh ./pakages/${JDK_VERSION}-${BitType}${rpm_suffix}
            echo "Install successfully!"        
            return
        fi
    done
    echo "No accessible jdk install pakage"
    exit
}

## Check computor bit type
BIT=$(getconf LONG_BIT)
if [ $BIT -eq 64 ]
then
    BitType=${X64Bit_Type}
else
    BitType=${X86Bit_Type}
fi

## Check jdk environment
echo "Checking JDK environment..."
if [ -z "$JAVA_HOME" ]; then
    JAVA_BIN="`which java 2>/dev/null || type java 2>&1`"
    if [ -x "$JAVA_BIN" ]; then
        echo "Java environment has been install."
        exit
    fi
else
    echo "Java environment has been install."
    exit
fi

## Start install jdk environment
jdkInstall ${BitType}

## Apply changed environment
source /etc/profile
source /etc/rc.local
echo "Jdk environment install complete!"
exit