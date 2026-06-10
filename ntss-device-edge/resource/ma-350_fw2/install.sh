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
CHECKFLG=`cat /etc/udev/rules.d/10-mae3xx.rules | grep "# USB Memory" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # USB Memory 作成済み
    echo 'USBmemory の自動マウントを設定済みです.'
else
    echo '' >> /etc/udev/rules.d/10-mae3xx.rules
    echo '# USB Memory' >> /etc/udev/rules.d/10-mae3xx.rules
    echo 'SUBSYSTEMS=="scsi", KERNEL=="sd[a-h]1",RUN+="/bin/mount /dev/%k /mnt/usb"' >> /etc/udev/rules.d/10-mae3xx.rules
echo set 'USBmemory の自動マウントを設定しました.'
fi
CHECKFLG=`cat /etc/udev/rules.d/10-mae3xx.rules | grep "# SD Card" | wc -l`
if [ $CHECKFLG -ne 0 ]; then
    # SD Card 作成済み
    echo 'SDcard の自動マウントを設定済みです.'
else
    echo '' >> /etc/udev/rules.d/10-mae3xx.rules
    echo '# SD Card' >> /etc/udev/rules.d/10-mae3xx.rules
    echo 'SUBSYSTEMS=="block", KERNEL=="mmcblk0p1",RUN+="/bin/mount /dev/%k /mnt/sd"' >> /etc/udev/rules.d/10-mae3xx.rules
echo set 'SDcard の自動マウントを設定しました.'
fi

# 通信確認
# ISLOOPEXIT=0
# while [ $ISLOOPEXIT -ne 1 ]
# do
#     CHECKFLG=`route | grep ppp | grep default | wc -l`
#     if [ $CHECKFLG -eq 1 ]; then
#         # ppp接続確立
#         ISLOOPEXIT=1
#     else
#         echo '無線ネットワークが確立していません.'
#         echo '5秒後に再確認します。'
#         sleep 5
#     fi
# done

# libpcap-dev 取得
# echo 'パケットキャプチャライブラリを取得します.'
# apt update
# apt install -y libpcap-dev

# アプリケーションインストールフォルダの作成
mkdir /home/ntss/ntss

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

echo 'パケットキャプチャモードかソケット通信モードかを設定します.'
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
    echo 'ソケット通信モードを使用します'
    COLLECT_APP='./ntss_sock.exe'
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

# サービス設定ファイルのコピー
cp -f /mnt/sd/setup/etc/rc.local /etc/rc.local
cp -f /mnt/sd/setup/etc/init/* /etc/init/

# overlay
echo 'config saveing...'
overlaycfg -s etc
overlaycfg -s home
overlaycfg -s other
echo 'success.'