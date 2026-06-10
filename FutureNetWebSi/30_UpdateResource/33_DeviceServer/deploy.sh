#!/bin/bash

DEPLOY_FILE_DIR=/root/DeployFileDir
INST_DIR=/var/lib/tomcat/webapps
DE_DIR=/efs/ntss-s3-root-service/DE_Updated/
IFE_DIR=/efs/ntss-s3-root-service/IFE_Updated/versionup
WAIT=10

set -eu

echo Processing start.

########################################
# Disk usage% check (warn only)
# - Always print current use%
# - WARN if: use% > 60 (do not exit)
########################################
check_usepct_or_warn() {
  max=70
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
  return 0
}

#########################################
# Device server version up
#########################################
echo Device server version up start

#########################################
# Disk usage% check
#########################################
check_usepct_or_warn

#########################################
# Check WAR file existence
##########################################
echo Check WAR file existence

required_wars=(
  "alive_moni.war"
  "alive_moni_auto.war"
  "data_gathering.war"
  "data_gathering_auto.war"
  "device_edge.war"
  "device_edge_updater.war"
  "ntss-client-comm.war"
  "ntss-coop-api.war"
  "ntss-m-notice.war"
  "ntss-web-api.war"
)

missing=0
for w in "${required_wars[@]}"; do
  if [ ! -f "/root/device_pkg/$w" ]; then
    echo "[ERROR] missing: /root/device_pkg/$w"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  echo "[ERROR] Abort before stopping tomcat (required war(s) missing)."
  exit 1
fi

echo "[INFO] All required wars exist. OK to stop tomcat."

#########################################
# Module move
#########################################
# Deploy directory create
mkdir -p /root/DeployFileDir/
mv -f /root/device_pkg/*.war /root/DeployFileDir/

# Move files : DE_Updated
mkdir -p "$DE_DIR"
{
  # If DE_Update*.zip exists, move the files.
  ZIP_GLOB='/root/device_pkg/DE_Updated/DE_Update*.zip'
  if compgen -G "$ZIP_GLOB" > /dev/null; then
    echo "[INFO] Move files: $DE_DIR"
    mv -f $ZIP_GLOB "$DE_DIR"
    chmod 744 "$DE_DIR"DE_Update*.zip
  else
    echo "[INFO] no DE_Update*.zip found under /root/device_pkg/DE_Updated/ (skip)"
  fi
}
# Move files : IFE_Updated
SRC_DIR="/root/device_pkg/IFE_Updated/versionup"
mkdir -p "$IFE_DIR"
{
  FILE_GLOB="$SRC_DIR/*"
  if compgen -G "$FILE_GLOB" > /dev/null; then
    echo "[INFO] Clean destination: remove all files under $IFE_DIR"
    # remove all files under
    rm -f "$IFE_DIR/"*

    echo "[INFO] Move files: $SRC_DIR -> $IFE_DIR"
    mv -f $FILE_GLOB "$IFE_DIR"
    chmod 744 "$IFE_DIR"/*
  else
    echo "[INFO] no files found under $SRC_DIR (skip)"
  fi
}

#########################################
# ServiceStop
#########################################
echo Stop tomcat.

systemctl stop tomcat.service

#########################################
# Delete oldest backup directory
#########################################
echo Delete oldest backup directory.
oldest_dir=$(ls -1dtr $INST_DIR.* 2>/dev/null | head -n 1); [ -n "$oldest_dir" ] && echo "Delete oldest backup directory -> $oldest_dir" && rm -rf "$oldest_dir"

#########################################
# FileBackup
#########################################
echo Backup the war file.

cp -af $INST_DIR $INST_DIR.`date "+%Y%m%d_%H%M%S"`

#########################################
# FileMove
#########################################
echo Copy the war file.

mv -f $DEPLOY_FILE_DIR/*.war $INST_DIR
chown -R tomcat:tomcat $INST_DIR/*.war
chmod 644 $INST_DIR/*.war

#########################################
# Delete existing directory
#########################################
echo Delete existing directories.

rm -rf $INST_DIR/alive_moni
rm -rf $INST_DIR/alive_moni_auto
rm -rf $INST_DIR/data_gathering
rm -rf $INST_DIR/data_gathering_auto
rm -rf $INST_DIR/device_edge
rm -rf $INST_DIR/device_edge_updater
rm -rf $INST_DIR/ntss-client-comm
rm -rf $INST_DIR/ntss-coop-api
rm -rf $INST_DIR/ntss-m-notice
rm -rf $INST_DIR/ntss-web-api

#########################################
# Update check
#########################################
echo Check update module.
echo ---------------------------------------------------------------------------
ls -la $INST_DIR
echo ---------------------------------------------------------------------------

#########################################
# ServiceStart
#########################################
echo Start tomcat.

systemctl start tomcat.service

echo Wait 3 seconds...

sleep 3s

echo Check tomcat.service status.
echo

systemctl status tomcat.service --no-pager

echo
echo
echo Processing complete !!

#########################################
# Inline service health check
#########################################
inline_service_health_check() {
  echo
  echo Check service status....
  echo The service is starting. Please wait up to 5 minutes...
  # check common setting
  BASE_URL="http://localhost:8080"
  HEADER="SSECCAYEK: NTSS-NKK-ESM-TDC-YSK"
  CURL_OPT=(-sS --fail --location --header "$HEADER")

  # service list
  services=(
   "alive_moni"
   "alive_moni_auto"
   "ntss-coop-api"
   "ntss-client-comm"
   "data_gathering"
   "device_edge"
   "device_edge_updater"
   "ntss-m-notice"
   "ntss-web-api"
  )

  for svc in "${services[@]}"; do
    printf "%-20s" "$svc"
    curl "${CURL_OPT[@]}" "${BASE_URL}/${svc}/actuator/health" || echo " DOWN (curl failed)"
    echo
  done
}

# service check
while true; do
  date
  ls --color=always -la "$INST_DIR"

  COUNT=$(find "$INST_DIR" -maxdepth 1 -type f | wc -l)
  if [ "$COUNT" -ge 10 ]; then
    echo 
    echo "Deployment complete"
    sleep $WAIT
    inline_service_health_check
    break
  fi

  sleep 2
done
