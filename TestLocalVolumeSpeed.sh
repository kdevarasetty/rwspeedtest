#!/bin/bash

#####################################################
#
#   This script will create test local volume on localhost
#   and perform com.mapr.fs.RWSpeedTest
#
#####################################################

testdate=$(date +"%Y%m%d%H%M%S")
testhostname=`hostname`_${testdate}
logFile=/tmp/${testhostname}_log.txt


nowTime=$(date +"%Y-%m-%d %H:%M:%S")
echo "${nowTime} INFO [$$]: LogFile - ${logFile}" | tee -a $logFile
echo "${nowTime} INFO [$$]: Creating localvolume ${testhostname}" | tee -a $logFile
maprcli volume create -name ${testhostname} -path /${testhostname} -replication 1 -localvolumehost `hostname -f`
if [ $? -ne 0 ]; then
        nowTime=$(date +"%Y-%m-%d %H:%M:%S")
		echo "${nowTime} ERROR [$$]: Could not create localvolume: ${testhostname}. Exiting.." | tee -a $logFile
	    exit 1
fi

nowTime=$(date +"%Y-%m-%d %H:%M:%S")
echo "${nowTime} INFO [$$]: Setting compression off for localvolume ${testhostname}" | tee -a $logFile
hadoop mfs -setcompression off /${testhostname}
if [ $? -ne 0 ]; then
        nowTime=$(date +"%Y-%m-%d %H:%M:%S")
                echo "${nowTime} ERROR [$$]: Could set compression off for localvolume: ${testhostname}. Exiting.." | tee -a $logFile
            exit 1
fi

nowTime=$(date +"%Y-%m-%d %H:%M:%S")
echo "${nowTime} INFO [$$]: Starting com.mapr.fs.RWSpeedTest for localvolume ${testhostname}" | tee -a $logFile
hadoop jar /opt/mapr/lib/maprfs-diagnostic-tools-5.*-mapr.jar com.mapr.fs.RWSpeedTest /${testhostname}/RWTestSingleTest 1024 maprfs:/// | tee -a $logFile

if [ $? -ne 0 ]; then
        nowTime=$(date +"%Y-%m-%d %H:%M:%S")
		echo "${nowTime} ERROR [$$]: Could not run com.mapr.fs.RWSpeedTest for localvolume ${testhostname}. Exiting.." | tee -a $logFile
	    exit 1
fi
nowTime=$(date +"%Y-%m-%d %H:%M:%S")
echo "${nowTime} INFO [$$]: Removing localvolume ${testhostname}" | tee -a $logFile
maprcli volume remove -name ${testhostname} -force 1
if [ $? -ne 0 ]; then
        nowTime=$(date +"%Y-%m-%d %H:%M:%S")
		echo "${nowTime} ERROR[$$]: Could not remove localvolume: ${testhostname}. Exiting.." | tee -a $logFile
	    exit 1
fi

exit 0