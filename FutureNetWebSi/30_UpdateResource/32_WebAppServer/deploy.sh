#!/bin/bash

#########################################
# Constant
#########################################
#DEPROY FILE
DEPROY_FILE_1=/root/DeployFileDir/ntss-admin-web.jar
DEPROY_FILE_2=/root/DeployFileDir/ntss-client-comm.jar

#SERVICE NAME
SERVICE_NAME_1=ntss_admin_web.service
SERVICE_NAME_2=ntss_client_comm.service

#INSTDIR FILE
INSTDIR_FILE_1=/var/lib/ntss-admin-web/ntss-admin-web.jar
INSTDIR_FILE_2=/var/lib/ntss-client-comm/ntss-client-comm.jar

#BACKUP FILE
BACKUP_FILE_1=/root/JAR_BACKUP/ntss-admin-web.jar
BACKUP_FILE_2=/root/JAR_BACKUP/ntss-client-comm.jar

########################################
# Disk usage% check (warn only)
# - Always print current use%
# - WARN if: use% > 60 (do not exit)
########################################
check_usepct_or_warn() {
  max=60
  p=/

  echo -------------------------------------------------------
  echo "[INFO] Disk usage% check (df -h):"
  df -h

  u=$(df -P "$p" 2>/dev/null | awk 'END{gsub(/%/,"",$5);print $5}') || {
    echo "[ERROR] Disk check failed: $p" >&2
    exit 1
  }

  # limmit orver
  if [ "$u" -gt "$max" ]; then
    echo "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*="
    echo "[WARN] Disk usage is high: $p (${u}% > ${max}%)" >&2
    echo "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*="
  fi
}

#############################################
# Function Deploy
#############################################
function deployfunc() {

    #########################################
    # CheckFileExistence
    #########################################
    echo Check file existence.    

    if [ ! -e $1 ]; then
        echo "File not found: $1" >&2
        return 1
    fi
    
    echo

    #########################################
    # ServiceStop
    #########################################
    echo Stop service.
    echo $2

    systemctl stop $2

    #########################################
    # Delete oldest backup file
    #########################################
    echo Delete oldest backup file.
    oldest=$(ls -1tr "$4".* 2>/dev/null | head -n 1); [ -n "$oldest" ] && echo "Delete oldest backup -> $oldest" && rm -f "$oldest"
    echo

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
    # UpdateModuleCheck
    #########################################
    echo Check update module.
    echo --------------------------------------------------------------------------------------------------
    ls -la $3
    echo --------------------------------------------------------------------------------------------------

    #########################################
    # ServiceStart
    #########################################
    echo Start service.

    systemctl start $2

    echo Wait 3 seconds...

    sleep 3s 

    echo Check $2
    echo 

    systemctl status $2 --no-pager

    echo
    echo
}


#############################################
# Entry point
#############################################
echo Pre-work......
# Disk usage% check
check_usepct_or_warn

mkdir -p /root/DeployFileDir/

# Move files : Application_Update
if [ -d "/root/webapp_pkg/Application_Update" ] && ls /root/webapp_pkg/Application_Update/* >/dev/null 2>&1; then
  echo "[INFO] Move files: /root/webapp_pkg/Application_Update -> /efs/ntss-s3-root-service/Application_Update"
  mkdir -p /efs/ntss-s3-root-service/Application_Update
  mv -f /root/webapp_pkg/Application_Update/* /efs/ntss-s3-root-service/Application_Update/
else
  echo "[INFO] No files to move from /root/webapp_pkg/Application_Update (skip)."
fi

# Move files : Model_Update
if [ -d "/root/webapp_pkg/Model_Update" ] && ls /root/webapp_pkg/Model_Update/* >/dev/null 2>&1; then
  echo "[INFO] Move files: /root/webapp_pkg/Model_Update -> /efs/ntss-s3-root-service/Model_Update"
  mkdir -p /efs/ntss-s3-root-service/Model_Update
  rsync -av /root/webapp_pkg/Model_Update/ /efs/ntss-s3-root-service/Model_Update/
  rm -rf /root/webapp_pkg/Model_Update/*
else
  echo "[INFO] No files to move from /root/webapp_pkg/Model_Update (skip)."
fi

## Move files : Default_Report
if [ -d "/root/webapp_pkg/default_report" ] && ls /root/webapp_pkg/default_report/* >/dev/null 2>&1; then
  echo "[INFO] Move files: /root/webapp_pkg/default_report -> /efs/default_report"
  mkdir -p /efs/default_report
  rsync -av /root/webapp_pkg/default_report/ /efs/default_report/
  rm -rf /root/webapp_pkg/default_report/*
else
  echo "[INFO] No files to move from /root/webapp_pkg/default_report (skip)."
fi

# Move files : *.jar
mv -f /root/webapp_pkg/*.jar /root/DeployFileDir/

echo Start deployment......

deployfunc  $DEPROY_FILE_1  $SERVICE_NAME_1  $INSTDIR_FILE_1  $BACKUP_FILE_1 || exit $?
deployfunc  $DEPROY_FILE_2  $SERVICE_NAME_2  $INSTDIR_FILE_2  $BACKUP_FILE_2 || exit $?

echo 
echo 
echo Processing complete !!

##################################################
# Waiting for the service to start
##################################################
echo
echo "Waiting for the service to start. Please wait. . . "
echo

wait_for_json_up() {
  local label="$1"
  local url="$2"
  local timeout="${3:-120}"
  local interval="${4:-2}"

  local start
  start=$(date +%s)

  while true; do
    local body
    if body="$(curl -sS --fail --location --connect-timeout 3 --max-time 5 "$url" 2>/dev/null)"; then
      if echo "$body" | grep -q '"status"[[:space:]]*:[[:space:]]*"UP"'; then
        printf "%-28s %s\n" "$label" "$body"
        return 0
      fi
    fi

    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then
      printf "%-28s %s\n" "$label" "curl failed (timeout)" >&2
      return 1
    fi

    sleep "$interval"
  done
}

wait_for_html_ok() {
  local label="$1"
  local url="$2"
  local timeout="${3:-120}"
  local interval="${4:-2}"

  local start
  start=$(date +%s)

  while true; do
    if curl -sS --fail --location --connect-timeout 3 --max-time 5 "$url" >/dev/null 2>/dev/null; then
      printf "%-28s %s\n" "$label" "{OK}"
      return 0
    fi

    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then
      printf "%-28s %s\n" "$label" "curl failed (timeout)" >&2
      return 1
    fi

    sleep "$interval"
  done
}

echo
echo "Check service status...."
echo

overall_rc=0

# ntss-client-comm (JSON health @ 8090)
wait_for_json_up "[INFO] ntss-client-comm" "http://localhost:8090/ntss-client-comm/actuator/health" 120 2 || overall_rc=1

# ntss-admin-web (HTML page @ 8080)
wait_for_html_ok "[INFO] ntss-admin-web" "http://localhost:8080/ntss-admin-web/" 120 2 || overall_rc=1

echo
exit "${overall_rc}"
