# Node-RED サービスの生成
## 環境変数の設定
mkdir /etc/sysconfig/
cp /home/ntss/ntss_if_setup/files/ntssif.env /etc/sysconfig/ntss
#chmod 766 /etc/sysconfig/ntss

## Node-RED サービスの設定
cp /home/ntss/ntss_if_setup/files/nodered.service /etc/systemd/system/nodered.service
#chmod 766 /etc/systemd/system/nodered.service

#
systemctl daemon-reload
systemctl enable nodered.service
sudo systemctl start nodered


