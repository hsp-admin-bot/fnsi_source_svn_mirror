-- FNSIユーザを追加します
sqlplus fnsiview/fnsiview@fnsiview @SQL\CREATE_USER.sql
-- FNSIユーザにFNSIVIEWユーザのテーブルを参照権限を付与するSQLの自動作成
sqlplus fnsiview/fnsiview@fnsiview @SQL\CREATE_GRANT.sql
-- FNSIユーザへの参照権限付与SQLの実行
sqlplus fnsiview/fnsiview@fnsiview @SQL\GRANT.sql
-- FNSIユーザがFNSIVIEWスキーマの指定なしでテーブル参照できるようにシノニム付与するSQLを自動作成
sqlplus fnsiview/fnsiview@fnsiview @SQL\CREATE_SYNONYM.sql
-- FNSIユーザへのシノニム付与SQLの実行
sqlplus fnsiview/fnsiview@fnsiview @SQL\SYNONYM.sql
exit
