# 2022-03-09 以下の操作はrootユーザーを使用して実行します。
# Ubuntu serverへのNode-REDセットアップ

<details><summary>ユーザの作成</summary><div>


### ubuntu ユーザを追加して sudo 権限をつける
[参考](https://qiita.com/white_aspara25/items/c1b9d02310b4731bfbaa)
- ユーザ追加
```
$ adduser ntss
```
- sudo グループに追加
```
$ gpasswd -a ntss sudo
```

### パスワードなしで`sudo`実行可能なコマンドの設定
```
$ sudo visudo -f /etc/sudoers.d/ntss
```

- 以下の通り設定
```
$ ntss ALL=(ALL) NOPASSWD:/bin/sh /home/ntss/if_edge/maint/maintenance.sh
```

</div></details>

---
<details><summary>ssh-serverインストール</summary><div>  

## ssh-server
```
$ sudo apt install -y openssh-server
```
</div></details>
---

---
<details><summary>ftpの設定</summary><div>  

## ftpの設定
[参考](https://yamaryu0508.hatenablog.com/entry/2014/12/02/102648)

- FTPサーバのインストール
```
$ sudo apt-get install vsftpd
```


- `/etc/vsftpd.conf`の設定
```
$ sudo vi /etc/vsftpd.conf

# （変更箇所のみ記載）
# anonymousでのFTPログイン
anonymous_enable=NO #anonymousユーザを禁止（デフォルトはYES）
 
# ユーザ権限設定
local_enable=YES #ローカルユーザを有効に（デフォルトはコメントアウト）
write_enable=YES #書き込み可能に（デフォルトではコメントアウト）
local_umask=077　　　#書き込んだ際のパーミッションのマスク（デフォルトではコメントアウト）
 
# ASCIIモードの設定
ascii_upload_enable=YES #アスキーでアップロードを有効（デフォルトではコメントアウト）
ascii_download_enable=YES　#アスキーでダウンロードの有効（デフォルトではコメントアウト）
 
# ユーザ権限
chroot_local_user=YES #ローカルユーザの制限（デフォルトではコメントアウト）
chroot_list_enable=YES　　#リストにより制限を行う（デフォルトではコメントアウト）
chroot_list_file=/etc/vsftpd.chroot_list #リストのパス
```

- `/etc/vsftpd.chroot_list`の設定
```
$ sudo vi /etc/vsftpd.chroot_list

ntss
```

- vsftpdの再起動
```
$ sudo service vsftpd restart
```
</div></details>
---




---
<details><summary>その他Node-RED等のインストール</summary><div>  
### 2022-03-09 以下の操作はntssユーザーを使用して実行します。
### setupファイルのupload
ffftpなどのツールで`home/ntss/`直下に`ntss_if_setup`ディレクトリごとコピーする

#### 1. node.jsなどのインストール
```
$ sudo sh /home/ntss/ntss_if_setup/01_install.sh
```
#### 2. Node-REDのインストール
```
$ sudo sh /home/ntss/ntss_if_setup/02_install_NodeRED.sh
```
#### 2022-03-09 処理を追加する
#### 3-0. ディレクトリの作成
```
$ cd /home/ntss
$ mkdir ~/.node-red
```
#### 3. node.js関連のパッケージのインストール
```
$ sudo sh /home/ntss/ntss_if_setup/03_install_nodePkg.sh
```
#### 4. ntss_ifで使用するディレクトリの作成
```
### 2022-03-09 04_setup_ntssIF.shのsudoを削除する
###$ sudo sh /home/ntss/ntss_if_setup/04_setup_ntssIF.sh
$ sh /home/ntss/ntss_if_setup/04_setup_ntssIF.sh
```

### 2023-02-08 bug #8334 IFエッジの動作ログが出力できていない 孫 start
#### 5. Node_Red のLogについて
##### ★★★
##### 「60-node-red.conf」ファイルの内容「string="/home/ntss/if_edge/logs/nodered/node-red_%$YEAR%%$MONTH%%$DAY%.log"」には次のような要件があります。
##### ①パス「/home/ntss/if_edge/logs/nodered」と「ntssif.env」の「NTSS_LOG_DIR_NODE_RED」指定のパスは一致しなければならない。
##### ②「04_setup_ntssIF.sh」の内容「mkdir logs/nodered/」により、このパス「/home/ntss/if_edge/logs/nodered」は作成されなければなりません。
##### ★★★
$ sudo sh /home/ntss/ntss_if_setup/05_setup_NodeRedLog.sh

#### システムの再起動
$ sudo reboot
### 2023-02-08 bug #8334 IFエッジの動作ログが出力できていない 孫 end

</div></details>

---


<details><summary>Node-REDで使用するパレットのインストール</summary><div>  

### Node-RED起動
- Node-REDを起動する
```
$ node-red
```
### 2022-03-09 以下`node`の追加処理は/home/ntss/ntss_if_setup/03_install_nodePkg.shを移動する。
### - webブラウザにてフローにアクセスし、右上の`ハンバーガーアイコン`をクリックし`パレットの管理`より以下の`node`を追加する
### ```
### node-red-contrib-zip
### node-red-contrib-flogger
### node-red-node-base64
### ```
- Node-REDを停止する( `ctrl` + `c` )



</div></details>

---

<details><summary>Node-REDで使用するファイルのコピー</summary><div>  

### ファイルのコピー
```
.node-red/custom_nodes/*
.node-red/lib/lib/*
.node-red/ntss_if.json
.node-red/ntss_maint.json
.node-red/settings.js

if_edge/conf/if_edge_setting.json
if_edge/conf/distribute.skip
if_edge/conf/receive.skip
if_edge/conf/send.skip
### 2022-03-09 ファイルを追加する
if_edge/conf/soapNecSi.wsdl
if_edge/conf/soapNecSiResponse.xml
```


</div></details>

---

<details><summary>Node-REDサービスの設定</summary><div>  

### 1. node.jsなどのインストール
~~~
$ sudo sh /home/ntss/ntss_if_setup/98_setup_NtssIfMaint_Service.sh
$ sudo sh /home/ntss/ntss_if_setup/99_setup_NodeRED_Service.sh
~~~

</div></details>

---


