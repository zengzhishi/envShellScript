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
VERSION="8.0.38"
TOMCAT_VERSION="apache-tomcat-${VERSION}"
PRE_TOMCAT_HOME="/usr/local/tomcat"
CATALINA_HOME="/usr/local/tomcat/tomcat"

## Checking JAVA environment before tomcat install
echo "Checking JDK environment..."
if [ -z "$JAVA_HOME" ]; then
    JAVA_BIN="`which java 2>/dev/null || type java 2>&1`"
    if [ ! -x "$JAVA_BIN" ]; then
        echo "Java environment is needed."
        exit
    fi
    JAVA_HOME="`dirname $JAVA_BIN`"
fi


################################################################
## Install tomcat environment                                 ##
## It has two type of install pakages: .tar.gz, .zip          ##
################################################################
tomcatInstall()
{
    BitType=$1
    pakages=$(ls ./pakages/$TOMCAT_VERSION*)
    if [ -d "./pakages" ]; then
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
    fi
    echo "No accessible tomcat install pakage in local. Now download from remote repository..."
    mkdir -p ./pakages
    subversion=${VERSION%%.*}
    url="http://archive.apache.org/dist/tomcat/tomcat-${subversion}/v${VERSION}/bin/${TOMCAT_VERSION}${gz_suffix}"
    wget -P ./pakages $url
    echo "Download complete, now installing..."
    tar -zxvf ${file}
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
}

################################################################
## Create tomcat daemon service                               ##
################################################################
configAsDaemon()
{
    cd $CATALINA_HOME/bin
    tar xvfz commons-daemon-native.tar.gz
    cd commons-daemon-1.0.15-native-src/unix
    ./configure --with-java=${JAVA_HOME}
    make
    cp jsvc ../..
    cd ../..

    CATALINA_BASE=$CATALINA_HOME
    cd $CATALINA_HOME
    ./bin/jsvc -user tomcat \
        -classpath $CATALINA_HOME/bin/bootstrap.jar:$CATALINA_HOME/bin/tomcat-juli.jar \
        -outfile $CATALINA_BASE/logs/catalina.out \
        -errfile $CATALINA_BASE/logs/catalina.err \
        -Dcatalina.home=$CATALINA_HOME \
        -Dcatalina.base=$CATALINA_BASE \
        -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
        -Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties \
        org.apache.catalina.startup.Bootstrap
    cp $CATALINA_HOME/bin/daemon.sh /etc/init.d/tomcat
    sed '/#!\/bin\/sh/a\$# chkconfig: 2345 10 90\n# description: Start and Stop tomcat by service\nsource \/etc\/profile' /etc/init.d/tomcat
    chmod a+x tomcat
    chkconfig add tomcat
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