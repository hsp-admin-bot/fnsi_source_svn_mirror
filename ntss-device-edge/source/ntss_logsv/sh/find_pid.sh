#!/bin/sh

# usage: find_pid {grepで探すプロセス名} {プロセスID格納ファイル} 

grepstr=${1}
response_file=${2}

pid=`ps -aux |grep -v grep |grep -v find_pid.sh |grep ${grepstr} | awk '{print $2}'`

echo ${pid} > ${response_file}
exit 0