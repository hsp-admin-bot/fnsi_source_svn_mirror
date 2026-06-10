#postgre再起動（接続のクリアのため）
#convert_dbへの接続が存在しないことを確認して続行
#systemctl restart postgresql-9.6.service

#ディレクトリの作成 -> done
mkdir -p /var/lib/pgsql/work
#mkdir -p /var/lib/pgsql/convert_db
#mkdir -p /var/lib/pgsql/convert_index
#chmod 777 /var/lib/pgsql/ -R
#chown postgres:postgres /var/lib/pgsql/ -R

#下記設定は環境により、異なるため、変更ください
#コンバートDBのhost
convert_db_host=dev-ntss-convert-service-cluster.cluster-chzddp07crsf.ap-northeast-1.rds.amazonaws.com
#FNSI DBのhost
fnsi_db_host=dev-ntss-platform-service-cluster.cluster-chzddp07crsf.ap-northeast-1.rds.amazonaws.com
#convert DB管理ユーザ
db_manage_user=dbuser
#db_manage_user=postgres

#convertロール、convert_dbの作成 -> done
psql -h $convert_db_host -U $db_manage_user -d postgres < ./create_convert_db_1.sql

#ntssスキーマ、バッチ起動に必要なテーブルの作成 -> done
psql -h $convert_db_host -U convert -d convert_db < ./create_convert_db_2.sql

#nkk4,nkk5,nkk6からテーブル定義の取得 -> done
pg_dump ntss_db4 -U nkk4 -s -O -c -h $fnsi_db_host --if-exists --schema-only> /var/lib/pgsql/work/ntss_db4.txt
pg_dump ntss_db5 -U nkk5 -s -O -c -h $fnsi_db_host --if-exists --schema-only> /var/lib/pgsql/work/ntss_db5.txt
pg_dump ntss_db6 -U nkk6 -s -O -c -h $fnsi_db_host --if-exists --schema-only> /var/lib/pgsql/work/ntss_db6.txt

#インデックスのテーブルスペース変更 ->done
#sed s/ntss_index4/convert_index/ /var/lib/pgsql/work/ntss_db4.txt > /var/lib/pgsql/work/ntss_db4.txt
#sed s/ntss_index5/convert_index/ /var/lib/pgsql/work/ntss_db5.txt > /var/lib/pgsql/work/ntss_db5.txt
#sed s/ntss_index6/convert_index/ /var/lib/pgsql/work/ntss_db6.txt > /var/lib/pgsql/work/ntss_db6.txt

sed 's/DROP SCHEMA/-- DROP SCHEMA/' /var/lib/pgsql/work/ntss_db4.txt > /var/lib/pgsql/work/ntss_db4rep_schema1.txt
sed 's/CREATE SCHEMA/-- CREATE SCHEMA/' /var/lib/pgsql/work/ntss_db4rep_schema1.txt > /var/lib/pgsql/work/ntss_db4rep_schema2.txt
sed 's/CREATE EXTENSION/-- CREATE EXTENSION/' /var/lib/pgsql/work/ntss_db4rep_schema2.txt > /var/lib/pgsql/work/ntss_db4rep_schema3.txt
sed 's/COMMENT ON EXTENSION/-- COMMENT ON EXTENSION/' /var/lib/pgsql/work/ntss_db4rep_schema3.txt > /var/lib/pgsql/work/ntss_db4rep_schema4.txt

sed 's/DROP SCHEMA/-- DROP SCHEMA/' /var/lib/pgsql/work/ntss_db5.txt > /var/lib/pgsql/work/ntss_db5rep_schema1.txt
sed 's/CREATE SCHEMA/-- CREATE SCHEMA/' /var/lib/pgsql/work/ntss_db5rep_schema1.txt > /var/lib/pgsql/work/ntss_db5rep_schema2.txt

sed 's/DROP SCHEMA/-- DROP SCHEMA/' /var/lib/pgsql/work/ntss_db6.txt > /var/lib/pgsql/work/ntss_db6rep_schema1.txt
sed 's/CREATE SCHEMA/-- CREATE SCHEMA/' /var/lib/pgsql/work/ntss_db6rep_schema1.txt > /var/lib/pgsql/work/ntss_db6rep_schema2.txt
sed 's/unq_ord_prescription/unq_ord_personal_prescription/' /var/lib/pgsql/work/ntss_db6rep_schema2.txt > /var/lib/pgsql/work/ntss_db6rep_prescription3.txt

#convert_dbへリストア
psql -h $convert_db_host -U convert -d convert_db < /var/lib/pgsql/work/ntss_db4rep_schema4.txt
psql -h $convert_db_host -U convert -d convert_db < /var/lib/pgsql/work/ntss_db5rep_schema2.txt
psql -h $convert_db_host -U convert -d convert_db < /var/lib/pgsql/work/ntss_db6rep_prescription3.txt

psql -h $convert_db_host -U $db_manage_user -d convert_db < ./create_convert_db_3.sql