#!/bin/sh

# 設定の書き込み

# rootユーザーのパスワード変更
echo 'ユーザー"root"のパスワードを変更します.'
ISLOOPEXIT=0
while [ $ISLOOPEXIT -ne 1 ]
do
    passwd root
    if [ $? -eq 0 ]; then
        ISLOOPEXIT=1
    else
        echo 'パスワードの変更に失敗しました.もう一度入力してください.'
    fi
done

# ntssユーザー作成
CHECKFLG=`cat /etc/passwd | grep "^ntss:" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # ntss 作成済み
    echo 'ユーザー "ntss" は作成されています.'
else
    useradd -m -s /bin/bash -p `perl -e "print(crypt('ntss', 'nk'));"` ntss
    gpasswd -a ntss sudo
    mkdir /home/ntss/.ssh
    mkdir /home/ntss/ntss
    chmod 700 /home/ntss/.ssh
    echo 'ユーザー "ntss" を作成しました.'
fi

# 標準ユーザー削除
CHECKFLG=`cat /etc/passwd | grep "user1" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # ユーザー1 あり
    $(userdel --remove user1)
    echo 'ユーザー "user1" を削除しました.'
else
    echo 'ユーザー "user1" は削除されています.'
fi

# 自動マウント設定
cp -f /mnt/sd/setup/etc/systemd/system/mnt-usb.mount /etc/systemd/system/
chmod 644 /etc/systemd/system/mnt-usb.mount
systemctl daemon-reload
systemctl enable mnt-usb.mount
systemctl start mnt-usb.mount
echo 'USBmemory の自動マウントを設定しました.'

cp -f /mnt/sd/setup/etc/systemd/system/mnt-sd.mount /etc/systemd/system/
chmod 644 /etc/systemd/system/mnt-sd.mount
systemctl daemon-reload
systemctl enable mnt-sd.mount
systemctl start mnt-sd.mount
echo 'SDcard の自動マウントを設定しました.'

# アプリケーションインストールフォルダの作成
mkdir -p /mnt/sd/ntss
mkdir -p /mnt/sd/ntss/conf
mkdir -p /mnt/sd/ntss/conf/sms
mkdir -p /mnt/sd/ntss/conf/sms/conf
mkdir -p /mnt/sd/ntss/mst
mkdir -p /mnt/sd/ntss/sh
mkdir -p /mnt/sd/ntss/version

# 設定ファイルの作成
ISLOOPEXIT=0
while [ $ISLOOPEXIT -ne 1 ]
do
    echo '施設コードを入力してください[6桁]'
    echo -n 'INPUT_FACILITY_CD: '
    read FACILITY_CD
    if [ ${#FACILITY_CD} -eq 6 ]; then
        ISLOOPEXIT=1
    else
        echo '施設コードは6桁固定です.もう一度入力してください.'
    fi
done
echo "施設コード[$FACILITY_CD]"

ISLOOPEXIT=0
while [ $ISLOOPEXIT -ne 1 ]
do
    echo 'デバイスエッジ番号を入力してください[0-99]'
    echo -n 'INPUT_DEVICE_EDGE_NO: '
    read DEVICE_EDGE_NO
    if [ $DEVICE_EDGE_NO -ge 0 -a $DEVICE_EDGE_NO -le 99 ]; then
        ISLOOPEXIT=1
    else
        echo 'デバイスエッジ番号は[0-99]です.もう一度入力してください.'
    fi
done
echo "デバイスエッジ番号[$DEVICE_EDGE_NO]"

ISLOOPEXIT=0
while [ $ISLOOPEXIT -ne 1 ]
do
    echo 'デバイスエッジのシリアルNoを入力してください[11桁]'
    echo -n 'INPUT_DEVICE_EDGE_SERIAL: '
    read DEVICE_EDGE_SERIAL
    if [ ${#DEVICE_EDGE_SERIAL} -eq 11 ]; then
        ISLOOPEXIT=1
    else
        echo 'デバイスエッジのシリアルNoは11桁固定です.もう一度入力してください.'
    fi
done
echo "デバイスエッジシリアルNo[$DEVICE_EDGE_SERIAL]"

echo 'パケットキャプチャモードかソケット通信モードか通信SVモードを設定します.'
echo -n 'パケットキャプチャモードを使用する場合は[y]を入力してください:'
read ISPCAPMODE
if [ "$ISPCAPMODE" = 'y' ]; then
    echo 'パケットキャプチャモードを使用します'
    COLLECT_APP='./ntss_pcap.exe'

    echo -n '監視する通信サーバーのIPアドレスを入力してください\n（何も入力しない場合は[192.168.1.10]となります）:'
    read COMSV_IP
    if [ ${#COMSV_IP} -eq 0 ]; then
        COMSV_IP='192.168.1.10'
    fi

    echo -n '監視するネットワークセグメントを入力してください\n（何も入力しない場合は[192.168.1.0]となります）:'
    read NET_SEG
    if [ ${#NET_SEG} -eq 0 ]; then
        NET_SEG='192.168.1.0'
    fi

else
  COMSV_IP='192.168.1.10'
  NET_SEG='192.168.1.0'
  echo -n 'ソケット通信モードを使用する場合は[y]を入力してください:'
  read ISSOCKMODE
  if [ "$ISSOCKMODE" = 'y' ]; then
      echo 'ソケット通信モードを使用します'
      COLLECT_APP='./ntss_sock.exe'
  else
      echo '通信SVモードを使用します'
      COLLECT_APP='./ntss_comsv.exe'
  fi
fi

# コピー前にサービスがあれば停止
service ntss stop
if [ $? -ne 0 ]; then
	echo 'ntssサービスは停止中です'
fi
service ntss-updater stop
if [ $? -ne 0 ]; then
	echo 'ntss-updaterサービスは停止中です'
fi
service ntss-logger stop
if [ $? -ne 0 ]; then
	echo 'ntss-loggerサービスは停止中です'
fi

# /homeディレクトリ下の古いモジュールファイルを削除
rm -f /home/ntss/ntss/*.exe
rm -f /home/ntss/ntss/*.txt
rm -f /home/ntss/ntss/*.sh
rm -f /home/ntss/ntss/*.list
rm -f /home/ntss/ntss/*.dat
rm -rf /home/ntss/ntss/conf
rm -rf /home/ntss/ntss/mst
rm -rf /home/ntss/ntss/sh
rm -rf /home/ntss/ntss/version
rm -rf /home/ntss/ntss/data

# FWバージョン
IS_FW7=`cat /etc/os-release | grep VERSION_ID=\"24 | wc -l`
IS_FW6=`cat /etc/os-release | grep VERSION_ID=\"22 | wc -l`
IS_FW5=`cat /etc/os-release | grep VERSION_ID=\"20 | wc -l`
if [ $IS_FW7 -eq 1 ]; then
    # FW7
    echo 'ファームウェア7.x環境です'
    DIR_EXE='exe_fw7'
    PKG_XXD='xxd_9.1.0016-1ubuntu7.9_armhf.deb'
    PKG_SMS='smstools_3.1.21-4_armhf.deb'
    echo 'CURLバイナリをコピーします'
    cp -f /mnt/sd/setup/package/curl /usr/local/bin/curl
    chmod 755 /usr/local/bin/curl
elif [ $IS_FW6 -eq 1 ]; then
    # FW6
    echo 'ファームウェア6.x環境です'
    DIR_EXE='exe_fw6'
    PKG_XXD='xxd_8.2.3995-1ubuntu2_armhf.deb'
    PKG_SMS='smstools_3.1.21-4_armhf.deb'
else
    # FW5
    echo 'ファームウェア5.x環境です'
    DIR_EXE='exe_fw5'
    PKG_XXD='xxd_8.1.2269-1ubuntu5_armhf.deb'
    PKG_SMS='smstools_3.1.21-3_armhf.deb'
fi


# #12332 2026.06.02 add stunnel対応 TDC片口 start
if [ $IS_FW7 -eq 1 ]; then
  # FW7の場合のみ、オンプレミスかどうかの判定
  echo -n 'クラウド環境で使用する場合は[y]を入力してください:'
  read USE_STUNNEL
  if [ "$USE_STUNNEL" = 'y' ]; then
      echo 'stunnel対応用の設定を適用します'
      PKG_STUNNEL='stunnel4_5.72-1build2_armhf.deb'
  else
      echo 'オンプレミス環境を使用します'
      PKG_STUNNEL=''
  fi
else
  # other
  PKG_STUNNEL=''
fi
# #12332 2026.06.02 add stunnel対応 TDC片口 end

# アプリケーションのコピー
cp -r /mnt/sd/execute/$DIR_EXE/*.exe /mnt/sd/ntss/
# その他のコピー
cp -r /mnt/sd/execute/conf /mnt/sd/ntss/
cp -r /mnt/sd/execute/mst /mnt/sd/ntss/
cp -r /mnt/sd/execute/sh /mnt/sd/ntss/
cp -r /mnt/sd/execute/version /mnt/sd/ntss/

# confファイルの設定
COMMON_CONF='/mnt/sd/ntss/conf/ntss_common.conf'
rm -f $COMMON_CONF
cat /mnt/sd/execute/conf/ntss_common.conf | while read line
do
    if [ "$(echo "$line" | grep -e 'FACILITY_CODE=')" ]; then
        echo "FACILITY_CODE=$FACILITY_CD" >> $COMMON_CONF
    elif [ "$(echo "$line" | grep -e 'AWS_IOT_DEVICE_NO=')" ]; then
        echo "AWS_IOT_DEVICE_NO=$DEVICE_EDGE_NO" >> $COMMON_CONF
    elif [ "$(echo "$line" | grep -e 'DEVICE_SERIAL_NO=')" ]; then
        echo "DEVICE_SERIAL_NO=$DEVICE_EDGE_SERIAL" >> $COMMON_CONF
    else
        echo "$line" >> $COMMON_CONF
    fi
done
UPD_CONF='/mnt/sd/ntss/conf/ntss_updater.conf'
rm -f $UPD_CONF
cat /mnt/sd/execute/conf/ntss_updater.conf | while read line
do
    if [ "$(echo "$line" | grep -e 'FACILITY_CODE=')" ]; then
        echo "FACILITY_CODE=$FACILITY_CD" >> $UPD_CONF
    elif [ "$(echo "$line" | grep -e 'AWS_IOT_DEVICE_NO=')" ]; then
        echo "AWS_IOT_DEVICE_NO=$DEVICE_EDGE_NO" >> $UPD_CONF
    elif [ "$(echo "$line" | grep -e 'DEVICE_SERIAL_NO=')" ]; then
        echo "DEVICE_SERIAL_NO=$DEVICE_EDGE_SERIAL" >> $UPD_CONF
    else
        echo "$line" >> $UPD_CONF
    fi
done
MAIN_CONF='/mnt/sd/ntss/conf/ntss_main.conf'
rm -f $MAIN_CONF
cat /mnt/sd/execute/conf/ntss_main.conf | while read line
do
    if [ "$(echo "$line" | grep -e 'COLLECT_APP=')" ]; then
        echo "COLLECT_APP=$COLLECT_APP" >> $MAIN_CONF
    else
        echo "$line" >> $MAIN_CONF
    fi
done

if [ "$ISPCAPMODE" = 'y' ]; then
    PCAP_CONF='/mnt/sd/ntss/conf/ntss_pcap.conf'
    rm -f $PCAP_CONF
    cat /mnt/sd/execute/conf/ntss_pcap.conf | while read line
    do
        if [ "$(echo "$line" | grep -e 'CAPTURE_FILTER=')" ]; then
            echo "CAPTURE_FILTER=tcp and net $NET_SEG mask 255.255.255.0 and ( dst port 7000 or dst port 7010 )" >> $PCAP_CONF
    elif [ "$(echo "$line" | grep -e 'FN_COMM_SERVER=')" ]; then
        echo "FN_COMM_SERVER=$COMSV_IP:7000/$COMSV_IP:7010" >> $PCAP_CONF
        else
            echo "$line" >> $PCAP_CONF
        fi
    done
fi

# #12332 2026.06.02 add stunnel対応 TDC片口 start
if [ "$USE_STUNNEL" = 'y' ]; then
    NETWORK_CONF='/mnt/sd/ntss/conf/ntss_network.conf'
    UPDATER_NETWORK_CONF='/mnt/sd/ntss/conf/ntss_updater_network.conf'
    rm -f $NETWORK_CONF
    rm -f $UPDATER_NETWORK_CONF
    AWS_URL=''
    while IFS= read -r line; do
        if [ "$(echo "$line" | grep -e 'AWS_HOST=')" ]; then
            AWS_URL=$(echo "$line" | cut -d '/' -f 3)
            echo "AWS_HOST=http://localhost:8443" >> $NETWORK_CONF
        else
            echo "$line" >> $NETWORK_CONF
        fi
    done < /mnt/sd/execute/conf/ntss_network.conf
    while IFS= read -r line; do
        if [ "$(echo "$line" | grep -e 'AWS_HOST=')" ]; then
            echo "AWS_HOST=http://localhost:8443" >> $UPDATER_NETWORK_CONF
        else
            echo "$line" >> $UPDATER_NETWORK_CONF
        fi
    done < /mnt/sd/execute/conf/ntss_updater_network.conf
fi
# #12332 2026.06.02 add stunnel対応 TDC片口 end

cp -f /mnt/sd/setup/etc/sysctl.conf /etc/
chmod 322 /etc/sysctl.conf
echo 'ARPパラメータ対応を設定しました.'

# サービス設定ファイルのコピー
CHECKFLG=`ls /etc/systemd/system/ | grep "ntss.service" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # NTSSサービス 作成済み
    echo '設定済み ntss サービスを書き換えます.'
    systemctl disable ntss.service
fi
cp -f /mnt/sd/setup/etc/systemd/system/ntss.service /etc/systemd/system/
chmod 644 /etc/systemd/system/ntss.service
systemctl daemon-reload
systemctl enable ntss.service
echo 'ntss サービスの自動起動を設定しました.'

CHECKFLG=`ls /etc/systemd/system/ | grep "ntss-updater.service" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # NTSSサービス 作成済み
    echo '設定済み ntss-updater サービスを書き換えます.'
    systemctl disable ntss-updater.service
fi
cp -f /mnt/sd/setup/etc/systemd/system/ntss-updater.service /etc/systemd/system/
chmod 644 /etc/systemd/system/ntss-updater.service
systemctl daemon-reload
systemctl enable ntss-updater.service
echo 'ntss-updater サービスの自動起動を設定しました.'

CHECKFLG=`ls /etc/systemd/system/ | grep "ntss-logger.service" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # NTSSサービス 作成済み
    echo '設定済み ntss-logger サービスを書き換えます.'
    systemctl disable ntss-logger.service
fi
cp -f /mnt/sd/setup/etc/systemd/system/ntss-logger.service /etc/systemd/system/
chmod 644 /etc/systemd/system/ntss-logger.service
systemctl daemon-reload
systemctl enable ntss-logger.service
echo 'ntss-logger サービスの自動起動を設定しました.'

# IPアドレス設定ファイルのバックアップ
mkdir -p /mnt/sd/setup/etc/network
cp -f /etc/network/interfaces /mnt/sd/setup/etc/network/interfaces
echo 'IPアドレス設定ファイルのバックアップを取得しました [/mnt/sd/setup/etc/network/interfaces]'

CHECKFLG=`ls /usr/bin/ | grep "xxd" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # xxd あり
    echo 'xxd がインストール済みですが上書きを行います.'
fi
echo 'xxd のインストールを開始します'
rm -rf /usr/bin/xxd
dpkg -i --force-downgrade /mnt/sd/setup/package/$PKG_XXD
echo 'xxd のインストールが完了しました'

CHECKFLG=`ls /etc/default/ | grep "smstools" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # sms-tools あり
    echo 'sms-tools がインストール済みですが上書きを行います.'
    systemctl disable smstools
    dpkg -r smstools
    rm -rf /etc/smsd.conf
    rm -rf /etc/default/smstools
fi

echo 'SMS有効化のためmobile_watchサービスを無効化します'
systemctl stop mobile_watch.path
systemctl stop mobile_watch.service
systemctl disable mobile_watch.path
systemctl disable mobile_watch.service

echo 'sms-tools のインストールを開始します'
rm -rf /var/spool/sms
dpkg -i --force-downgrade /mnt/sd/setup/package/libmm14_1.4.2-6_armhf.deb
dpkg -i --force-downgrade /mnt/sd/setup/package/$PKG_SMS
echo 'sms-tools のインストールが完了しました'

cp -f /mnt/sd/setup/package/smsd.conf /etc/
cp -f /mnt/sd/setup/package/smstools /etc/default/
chmod 644 /etc/default/smstools

systemctl enable smstools.service
echo 'smstools サービスの自動起動を設定しました.'

# #12332 2026.06.02 add stunnel対応 TDC片口 start
if [ "$USE_STUNNEL" = 'y' ]; then
	echo 'stunnel4 のインストールを開始します'
	dpkg -i --force-downgrade /mnt/sd/setup/package/$PKG_STUNNEL
	echo 'stunnel4 のインストールが完了しました'

	cp -f /mnt/sd/setup/package/stunnel.conf /etc/stunnel/
	
	echo "バイパス先URL:$AWS_URL:443"
	
    TARGET_CONF='/etc/stunnel/stunnel.conf'
    rm -f $TARGET_CONF
    while IFS= read -r line; do
        if [ "$(echo "$line" | grep -e 'connect =')" ]; then
            echo "connect = $AWS_URL:443" >> $TARGET_CONF
        else
            echo "$line" >> $TARGET_CONF
        fi
    done < /mnt/sd/setup/package/stunnel.conf
    
	chmod 644 /etc/stunnel/stunnel.conf

	systemctl enable stunnel4.service
	echo 'stunnel4 サービスの自動起動を設定しました.'
fi
# #12332 2026.06.02 add stunnel対応 TDC片口 end

# confファイルの警報/モニタデータ用フォルダ作成
while read line
do
  # 緊急発報用ファイル格納先フォルダ
  if [ "$(echo "$line" | grep -e 'M_NOTICE_FOLDER')" ]; then
      mkdir -p $(echo "$line" | cut -d '=' -f 2)
  # データ収集用ファイル格納先フォルダ
  elif [ "$(echo "$line" | grep -e 'DATA_COLLECT_FOLDER')" ]; then
      mkdir -p $(echo "$line" | cut -d '=' -f 2)
  fi
done < $COMMON_CONF


# overlay
echo 'config saving...'
overlaycfg -s etc
echo '[1/3]success'
overlaycfg -s home
echo '[2/3]success'
overlaycfg -s other -u
echo '[3/3]success.'
