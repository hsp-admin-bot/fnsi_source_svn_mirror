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

# アプリケーションインストールフォルダの作成
mkdir -p /home/ntss/ntss
mkdir -p /home/ntss/ntss/conf
mkdir -p /home/ntss/ntss/conf/sms
mkdir -p /home/ntss/ntss/conf/sms/conf
mkdir -p /home/ntss/ntss/mst
mkdir -p /home/ntss/ntss/sh
mkdir -p /home/ntss/ntss/version

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
# アプリケーションのコピー
cp -r /mnt/sd/execute/* /home/ntss/ntss/

# confファイルの設定
COMMON_CONF='/home/ntss/ntss/conf/ntss_common.conf'
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
UPD_CONF='/home/ntss/ntss/conf/ntss_updater.conf'
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
MAIN_CONF='/home/ntss/ntss/conf/ntss_main.conf'
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
    PCAP_CONF='/home/ntss/ntss/conf/ntss_pcap.conf'
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

# 自動マウント設定
cp -f /mnt/sd/setup/etc/systemd/system/mnt-usb.mount /etc/systemd/system/
systemctl daemon-reload
systemctl enable mnt-usb.mount
echo 'USBmemory の自動マウントを設定しました.'

cp -f /mnt/sd/setup/etc/systemd/system/mnt-sd.mount /etc/systemd/system/
systemctl daemon-reload
systemctl enable mnt-sd.mount
echo 'SDcard の自動マウントを設定しました.'

# サービス設定ファイルのコピー
CHECKFLG=`ls /etc/systemd/system/ | grep "ntss.service" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # NTSSサービス 作成済み
    echo 'ntss サービスを設定済みです.'
else
    cp -f /mnt/sd/setup/etc/systemd/system/ntss.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable ntss.service
    echo 'ntss サービスの自動起動を設定しました.'
fi

CHECKFLG=`ls /etc/systemd/system/ | grep "ntss-updater.service" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # NTSSサービス 作成済み
    echo 'ntss-updater サービスを設定済みです.'
else
    cp -f /mnt/sd/setup/etc/systemd/system/ntss-updater.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable ntss-updater.service
    echo 'ntss-updater サービスの自動起動を設定しました.'
fi

CHECKFLG=`ls /etc/systemd/system/ | grep "ntss-logger.service" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # NTSSサービス 作成済み
    echo 'ntss-logger サービスを設定済みです.'
else
    cp -f /mnt/sd/setup/etc/systemd/system/ntss-logger.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable ntss-logger.service
    echo 'ntss-logger サービスの自動起動を設定しました.'
fi

CHECKFLG=`ls /usr/bin/ | grep "xxd" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # xxd あり
    echo 'xxd がインストール済みですが上書きを行います.'
fi
echo 'xxd のインストールを開始します'
sudo rm -rf /usr/bin/xxd
sudo dpkg -i --force-downgrade /mnt/sd/setup/package/xxd_8.1.2269-1ubuntu5_armhf.deb
echo 'xxd のインストールが完了しました'

CHECKFLG=`ls /etc/default/ | grep "smstools" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # sms-tools あり
    echo 'sms-tools がインストール済みですが上書きを行います.'
fi
echo 'sms-tools のインストールを開始します'
sudo rm -rf /var/spool/sms
sudo dpkg -i --force-downgrade /mnt/sd/setup/package/libmm14_1.4.2-5ubuntu4_armhf.deb
sudo dpkg -i --force-downgrade /mnt/sd/setup/package/smstools_3.1.21-2_armhf.deb
echo 'sms-tools のインストールが完了しました'

cp -f /mnt/sd/setup/package/smsd.conf /etc/
cp -f /mnt/sd/setup/package/smstools /etc/default/

systemctl enable smstools.service
echo 'smstools サービスの自動起動を設定しました.'


# overlay
echo 'config saving...'
overlaycfg -s etc
echo '[1/3]success'
overlaycfg -s home
echo '[2/3]success'
overlaycfg -s other -u
echo '[3/3]success.'
