#postgre再起動（接続のクリアのため）
#convert_dbへの接続が存在しないことを確認して続行
#systemctl restart postgresql-9.6.service
#コンバートDBのhost
convert_db_host=dev-ntss-convert-service-cluster.cluster-chzddp07crsf.ap-northeast-1.rds.amazonaws.com
#DB管理ユーザ
db_manage_user=dbuser
#convertロール、convert_dbの削除 -> done
psql -h $convert_db_host -U $db_manage_user -d postgres < ./drop_convert_db_1.sql
