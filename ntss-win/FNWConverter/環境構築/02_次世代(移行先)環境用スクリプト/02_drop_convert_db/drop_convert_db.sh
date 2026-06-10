#postgre再起動（接続のクリアのため）
#convert_dbへの接続が存在しないことを確認して続行
#systemctl restart postgresql-9.6.service

#コンバートDBのhost
convert_db_host=192.168.100.40
#DB管理ユーザ
db_manage_user=root
#db_manage_user=postgres

#convertロール、convert_dbの削除 -> done
psql -h $convert_db_host -U $db_manage_user -d postgres < ./drop_convert_db_1.sql