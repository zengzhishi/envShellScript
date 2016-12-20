#!/bin/bash

################################################################
## This script will install tomcat8.0.38                      ##
## for znsh as a basic environment.                           ##
## Author: zzs                                                ##
## Date: 2016.11.22                                           ##
################################################################

X64Bit_Type="x64"
X86Bit_Type="i586"
gz_suffix=".tar.gz"
zip_suffix=".zip"
TOMCAT_VERSION="apache-tomcat-8.0.38"
PRE_TOMCAT_HOME="/usr/local/tomcat"
CATALINA_HOME="/usr/local/tomcat/tomcat"
export $CATALINA_HOME

echo "Checking JDK environment..."
checkResult=$(rpm -qa | grep java)
if [ -n checkResult -o -d /usr/local/jdk ]; then
    echo "Java environment are requred!"
    exit
fi

################################################################
## Install tomcat environment                                 ##
## It has two type of install pakages: .tar.gz, .zip          ##
################################################################
tomcatInstall()
{
    BitType=$1
    pakages=$(ls ./pakages/$TOMCAT_VERSION*)
    for file in ${pakages}
    do
        fileName=$(echo $file | cut -d '/' -f 3)
        if [ ${TOMCAT_VERSION}${gz_suffix} = ${fileName} ]
        then
            tar -zxvf ${file}
        elif [ ${TOMCAT_VERSION}${zip_suffix} = ${fileName} ]
        then
            unzip ${file}
        else
            continue
        fi
        mkdir -p ${PRE_TOMCAT_HOME}
        mv ${TOMCAT_VERSION} ${PRE_TOMCAT_HOME}
        ln -s ${PRE_TOMCAT_HOME}/${TOMCAT_VERSION} ${CATALINA_HOME}
        adduser tomcat
        chown -R tomcat:tomcat ${PRE_TOMCAT_HOME}
        echo "" >> /etc/profile
        echo "## Tomcat environment" >> /etc/profile
        echo "CATALINA_HOME=${CATALINA_HOME}" >> /etc/profile
        source /etc/profile
        echo "Install successfully!"
        return
    done
    echo "No accessible tomcat install pakage"
    exit
}

configAsDaemon()
{
    cd $CATALINA_HOME/bin
    tar xvfz commons-daemon-native.tar.gz
    cd commons-daemon-1.0.15-native-src/unix
    ./configure --with-java=${JAVA_HOME}
    make
    cp jsvc ../..
    cd ../..
}


## Check computor bit type
BIT=$(getconf LONG_BIT)
if [ $BIT -eq 64 ]
then
    BitType=${X64Bit_Type}
else
    BitType=${X86Bit_Type}
fi

## Check tomcat environment
echo "Checking tomcat environment..."
if [ -d /usr/local/tomcat ]; then
    echo "Tomcat environment has been exist!"
else
    tomcatInstall ${BitType}
    configAsDaemon
fi


## Apply changed environment
echo "Tomcat environment install complete!"
exit