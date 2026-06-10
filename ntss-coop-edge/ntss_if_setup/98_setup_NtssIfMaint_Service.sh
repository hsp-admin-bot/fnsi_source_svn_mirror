# Node-RED NTSS-if サービスの生成
## 環境変数の設定
mkdir /etc/sysconfig/
cp /home/ntss/ntss_if_setup/files/ntssif.env /etc/sysconfig/ntss

## Node-RED サービスの設定
cp /home/ntss/ntss_if_setup/files/ntssifmaint.service /etc/systemd/system/ntssifmaint.service

# NTSS-If-サービスの起動
systemctl daemon-reload
systemctl enable ntssifmaint.service
sudo systemctl start ntssifmaint


