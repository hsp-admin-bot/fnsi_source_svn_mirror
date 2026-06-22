mongodbへIndexを作成時の手順（踏み台サーバ（AmazonLinux2）前提）
１．踏み台サーバへ実行要スクリプトファイルを格納
　詳細：現時点20230629時点スクリプトファイル
　　①create_ind_history_collection_index.js
　　②create_log_event_collection_index.js
　　③create_pat_unique_history_collection_index.js

２．踏み台サーバへ接続
　詳細：略

３．mongoshで対象mongodbへ接続
　詳細：
　　旧コマンド：mongo、新コマンド：mongosh
　　接続成功の場合、mongoshのプロンプトに切り替える
　　※mongodbまたはmongoshがインストールされていない場合は付録のインストール手順参照
　　
　　接続コマンド両方実行可能：
　　　旧monngo  ：mongo --host <host> --port <port> ntss --username <username> --password <password>
　　　or
　　　新monngosh：mongosh --host <host> --port <port> ntss --username <username> --password <password>

４．index作成スクリプトファイルを実行
　詳細：コマンドプロンプトで「load(<ファイルパス>)」を入力、実行成功するとtrueがリターンされる。早くて5分、データ量次第で変動される。
　例：rs0 [direct: primary] ntss> load("/tmp/mongo/create_ind_history_collection_index.js")
　　　rs0 [direct: primary] ntss> load("/tmp/mongo/create_log_event_collection_index.js")
　　　rs0 [direct: primary] ntss> load("/tmp/mongo/create_pat_unique_history_collection_index.js")
　　　rs0 [direct: primary] ntss> load("/tmp/mongo/create_pat_group_detail_history_collection_index.js")
　　　rs0 [direct: primary] ntss> load("/tmp/mongo/create_pat_insurance_history_collection_index.js")
　　　rs0 [direct: primary] ntss> load("/tmp/mongo/create_pat_main_history_collection_index.js")
　　　rs0 [direct: primary] ntss> load("/tmp/mongo/create_pat_personal_main_history_collection_index.js")
５．mongoshを終了させる
　詳細：コマンドプロンプトで「quit」を入力

=======================
踏み台サーバ（AmazonLinux2）でmongoshをインストール手順

１．リポジトリファイルを作成
[root@ipアドレス ~]# vi /etc/yum.repos.d/mongodb-org-6.0.repo
------分割線のみ------
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/$releasever/mongodb-org/6.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
------分割線のみ------

２．yumでインストールを実行
[root@ipアドレス ~]# sudo yum install -y mongodb-org-shell

３．#10922にてMongoDBにインデックス追加
db.pat_personal_main_history.dropIndex("pat_id_1");
db.pat_personal_main_history.createIndex( { pat_id: 1 } );

