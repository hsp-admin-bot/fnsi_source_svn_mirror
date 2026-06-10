#ディレクトリの作成
mkdir -p pgsql/work
chmod -R 755 pgsql/work
#convert_dbのhost
convert_db_host=dev-ntss-convert-service-cluster.cluster-chzddp07crsf.ap-northeast-1.rds.amazonaws.com
#FNWSi本体側DBのhost
fnsi_db_host=dev-ntss-platform-service-cluster.cluster-chzddp07crsf.ap-northeast-1.rds.amazonaws.com
#convert DB管理ユーザ
db_manage_user=dbuser
db_convert_user=convert

#convertロール、convert_dbの作成
echo "convert_dbの作成"
convert_db=convert_db
psql -h $convert_db_host -U $db_manage_user -d postgres < ./create_convert_db_1.sql

#ntssスキーマ、バッチ起動に必要なテーブルの作成
echo "コンバートテーブルの作成(convert_db)"
psql -h $convert_db_host -U convert -d $convert_db < ./create_convert_db_2.sql

#nkk4,nkk5,nkk6からテーブル定義の取得
echo "DB4の構造出力"
pg_dump ntss_db4 -U nkk4 -s -O -c -h $fnsi_db_host --if-exists --schema-only> pgsql/work/ntss_db4.txt
echo "DB5の構造出力"
pg_dump ntss_db5 -U nkk5 -s -O -c -h $fnsi_db_host --if-exists --schema-only> pgsql/work/ntss_db5.txt
echo "DB6の構造出力"
pg_dump ntss_db6 -U nkk6 -s -O -c -h $fnsi_db_host --if-exists --schema-only> pgsql/work/ntss_db6.txt

#DB4のテーブル定義からスキーマ削除/作成をコメントアウト
sed 's/DROP SCHEMA/-- DROP SCHEMA/' pgsql/work/ntss_db4.txt > pgsql/work/ntss_db4rep_schema1.txt
sed 's/CREATE SCHEMA/-- CREATE SCHEMA/' pgsql/work/ntss_db4rep_schema1.txt > pgsql/work/ntss_db4rep_schema2.txt
#DB4のテーブル定義からEXTENSION作成をコメントアウト
sed 's/CREATE EXTENSION/-- CREATE EXTENSION/' pgsql/work/ntss_db4rep_schema2.txt > pgsql/work/ntss_db4rep_schema3.txt
sed 's/COMMENT ON EXTENSION/-- COMMENT ON EXTENSION/' pgsql/work/ntss_db4rep_schema3.txt > pgsql/work/ntss_db4rep_schema4.txt

#DB5のテーブル定義からスキーマ削除/作成をコメントアウト
sed 's/DROP SCHEMA/-- DROP SCHEMA/' pgsql/work/ntss_db5.txt > pgsql/work/ntss_db5rep_schema1.txt
sed 's/CREATE SCHEMA/-- CREATE SCHEMA/' pgsql/work/ntss_db5rep_schema1.txt > pgsql/work/ntss_db5rep_schema2.txt

#DB6のテーブル定義からスキーマ削除/作成をコメントアウト
sed 's/DROP SCHEMA/-- DROP SCHEMA/' pgsql/work/ntss_db6.txt > pgsql/work/ntss_db6rep_schema1.txt
sed 's/CREATE SCHEMA/-- CREATE SCHEMA/' pgsql/work/ntss_db6rep_schema1.txt > pgsql/work/ntss_db6rep_schema2.txt

#convert_dbへリストア
echo "convert_dbへのリストア"
psql -h $convert_db_host -U convert -d $convert_db < pgsql/work/ntss_db4rep_schema4.txt
psql -h $convert_db_host -U convert -d $convert_db < pgsql/work/ntss_db5rep_schema2.txt
psql -h $convert_db_host -U convert -d $convert_db < pgsql/work/ntss_db6rep_schema2.txt

#11690 start
convert_db_user="convert"
convert_db_name="convert_db"
ntss_db4_user="nkk4"
ntss_db4_name="ntss_db4"
ntss_db5_user="nkk5"
ntss_db5_name="ntss_db5"
ntss_db6_user="nkk6"
ntss_db6_name="ntss_db6"

max_version4=$(psql -h "$fnsi_db_host" -U "$ntss_db4_user" -d "$ntss_db4_name" -t -c "SELECT MAX(version) FROM ntss.flyway_schema_history;" | tr -d '[:space:]')
max_version5=$(psql -h "$fnsi_db_host" -U "$ntss_db5_user" -d "$ntss_db5_name" -t -c "SELECT MAX(version) FROM ntss.flyway_schema_history;" | tr -d '[:space:]')
max_version6=$(psql -h "$fnsi_db_host" -U "$ntss_db6_user" -d "$ntss_db6_name" -t -c "SELECT MAX(version) FROM ntss.flyway_schema_history;" | tr -d '[:space:]')

if [[ -z "$max_version4" ]]; then
    max_version4="1"
fi
if [[ -z "$max_version5" ]]; then
    max_version5="1"
fi
if [[ -z "$max_version6" ]]; then
    max_version6="1"
fi

update_query4="UPDATE ntss.flyway_schema_history_db4 SET version = '$max_version4' WHERE installed_rank = 1;"
update_query5="UPDATE ntss.flyway_schema_history_db5 SET version = '$max_version5' WHERE installed_rank = 1;"
update_query6="UPDATE ntss.flyway_schema_history_db6 SET version = '$max_version6' WHERE installed_rank = 1;"

psql -h "$convert_db_host" -U "$convert_db_user" -d "$convert_db_name" -c "$update_query4"
psql -h "$convert_db_host" -U "$convert_db_user" -d "$convert_db_name" -c "$update_query5"
psql -h "$convert_db_host" -U "$convert_db_user" -d "$convert_db_name" -c "$update_query6"
#11690 end

#convert_dbへの制約処理追加
echo "convert_dbへの制約処理"
psql -h $convert_db_host -U $db_manage_user -d $convert_db < ./create_convert_db_3.sql
echo "convert_dbカラム変更"
psql -h $convert_db_host -U $db_manage_user -d $convert_db < ./create_convert_db_4.sql
echo "既存の主キー制約を削除（冪等）,デフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）"
psql -h $convert_db_host -U $db_manage_user -d $convert_db < ./create_convert_db_5.sql
echo "新しい主キー列 convert_id 用のシーケンスを作成（冪等）,convert_id 列を追加し、主キーに設定（冪等）"
psql -h $convert_db_host -U $db_convert_user -d $convert_db < ./create_convert_db_6.sql
