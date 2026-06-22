#!/bin/sh

# usage: send_signal {grepで探すプロセス名} {シグナル番号}

grepstr=${1}
signalnum=${2}

ps -aux |grep -v grep |grep -v send_signal.sh |grep ${grepstr} |  awk '{print $2}' | xargs -I{} sudo kill -${signalnum} {}
