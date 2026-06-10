#!/bin/sh

# FWアップデートした際に残っているパッケージを初期化する

echo 'ファームウェアのメジャーバージョンをアップデートした端末では、パッケージ情報を初期化しないと正常にシステムがインストールできません。'
echo 'そのため、アップデートとパッケージ情報を初期化を行います。'
echo '実行する場合は[y]を入力してください:'
read ISINITIALIZE
if [ "$ISINITIALIZE" != 'y' ]; then
  # 実行しない
  exit
fi
  
CHECKFLG=`ls firmware/ | grep -E "mae3xx*" | grep -E "*.img" | wc -l`
if [ $CHECKFLG -eq 0 ]; then
  echo '使用するファームウェアファイル(mae3xx_*.img)をfirmwareフォルダに配置してください.'
  exit
fi

echo 'smstoolsの設定を削除します...'
systemctl disable smstools
rm -rf /etc/smsd.conf
rm -rf /etc/default/smstools*

echo 'ファームウェアの更新を行います...'
firmup firmware/mae3xx_*.img

echo 'パッケージ情報の初期化を行います...'
mount_overlay
rm -rf /rw.tmpfs/.overlay/overlays_other.tar.xz

echo 'OSを再起動します...'
reboot