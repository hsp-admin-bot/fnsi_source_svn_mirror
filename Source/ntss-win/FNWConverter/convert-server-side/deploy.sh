#!/bin/bash

#########################################
# Constant
#########################################
#DEPROY FILE
DEPROY_FILE_1=/home/ec2-user/DeployFileDir/convert-server-side.jar
#SERVICE NAME
SERVICE_NAME_1=ntss_convert.service
#INSTDIR FILE
INSTDIR_FILE_1=/var/lib/ntss-convert/convert-server-side.jar
#BACKUP FILE
BACKUP_FILE_1=/root/JAR_BACKUP/convert-server-side.jar

#############################################
# Function Deploy
#############################################
function deployfunc() {

    #########################################
    # CheckFileExistence
    #########################################
    echo Check file existence.

    if [ ! -e $1 ]; then
        echo File not found.
        echo $1
        return
    fi

    echo

    #########################################
    # ServiceStop
    #########################################
    echo Stop service.
    echo $2

    systemctl stop $2

    #########################################
    # FileBackup
    #########################################
    echo Backup the jar file.

    cp -pf $3 $4.`date "+%Y%m%d_%H%M%S"`

    #########################################
    # FileMove
    #########################################
    echo Move the jar file.

    mv -f $1 $3

    while [ ! -e $3 ]
    do
      sleep 0.5s
      echo "Wait for file transfer completion........"
    done

    chown nkkuser:nkkuser $3
    chmod 755 $3

    #########################################
    # ServiceStart
    #########################################
    echo Start service.

    systemctl start $2

    echo Wait 3 seconds...

    sleep 3s

    echo Check $2
    echo

    systemctl status $2

    echo
    echo
}

#############################################
# Entry point
#############################################
echo Start deployment......

deployfunc  $DEPROY_FILE_1  $SERVICE_NAME_1  $INSTDIR_FILE_1  $BACKUP_FILE_1

echo
echo
echo Processing complete !!


