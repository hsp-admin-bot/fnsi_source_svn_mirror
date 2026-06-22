apt-get update
apt-get install -y node.js npm
npm install n -g
# 最新LTSバージョンを指定してインストール
n 24.15.0
apt purge -y node.js npm
apt-get install -y openssh-server
apt-get install vsftpd
apt-get install cifs-utils
apt-get install autofs
apt-get install nkf
sudo reboot

