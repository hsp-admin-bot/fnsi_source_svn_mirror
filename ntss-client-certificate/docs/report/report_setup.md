## WebAppサーバーのインターネット接続
WebAppサーバーのアウトバウンドを確認し、WebAppサーバーからインターネットに出れることを確認する。
出れない場合は一時的にEIPを設定する必要がある。
作業終了後に解除すること。

## WebAppサーバーに接続
teratermでWebAppサーバーに接続

rootユーザーに変更
sudo su -



## Node.jsのインストール

curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
yum -y install nodejs

npm -v
node -v
確認以下のコマンドでバージョンが表示されればOK



## Highcharts export serverのインストール

npm install highcharts-export-server -g --unsafe-perm

/usr/lib/node_modules/highcharts-export-server
のパーミッションを確認する。




## wkhtmltopdfのインストール

yum -y install libXrender libXext

wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

tar Jxfv wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

cp wkhtmltox/bin/wkhtmltoimage /usr/local/bin/

cp wkhtmltox/bin/wkhtmltopdf /usr/local/bin/

rm -f wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

rm -rf wkhtmltox

wget https://ipafont.ipa.go.jp/IPAexfont/IPAexfont00401.zip

unzip IPAexfont00401.zip

mv IPAexfont00401 /usr/share/fonts

rm -f IPAexfont00401.zip

fc-cache -fv

cd /usr/share/fonts/IPAexfont00401

chmod 755 ipaexg.ttf
chmod 755 ipaexm.ttf


sudo su - nkkuser

fc-cache -fv


wkhtmltopdf http://www.yahoo.co.jp yahoo.pdf
で完成したPDFが日本語であること。


