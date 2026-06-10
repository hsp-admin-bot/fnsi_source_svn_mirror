# DB構成

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `DB構成`
- Category: guide

## Content

| 【DB構成】 | col2 | col3 | col4 | 【DB作成手順】 | col6 |
| --- | --- | --- | --- | --- | --- |
|  | ■ログインロール |  |  |  | ■ロール（ユーザ）作成 |
|  | 設定名 | 値 | 備考 |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d postgres -U dbuser |
|  | 個人情報管理ユーザ |  |  |  | create user nkk6 ENCRYPTED PASSWORD 'nkk6' CREATEDB CREATEROLE; |
|  | ロール名 | nkk6 | 小文字 |  | create user nkk5 ENCRYPTED PASSWORD 'nkk5' CREATEDB CREATEROLE; |
|  | パスワード | nkk6 | 小文字 |  | create user nkk4 ENCRYPTED PASSWORD 'nkk4' CREATEDB CREATEROLE; |
|  | データベース作成権限 | ON |  |  | ※dbuser(cloudpack提供)ユーザでは「SUPERUSER」「REPLICATION」を付与できない |
|  | ロール作成権限 | ON |  |  |  |
|  | 医療情報管理ユーザ |  |  |  |  |
|  | ロール名 | nkk5 | 小文字 |  |  |
|  | パスワード | nkk5 | 小文字 |  |  |
|  | データベース作成権限 | ON |  |  |  |
|  | ロール作成権限 | ON |  |  |  |
|  | 認証管理ユーザ |  |  |  |  |
|  | ロール名 | nkk4 | 小文字 |  |  |
|  | パスワード | nkk4 | 小文字 |  |  |
|  | データベース作成権限 | ON |  |  |  |
|  | ロール作成権限 | ON |  |  |  |
|  | ■テーブル空間 |  |  |  | ■テーブルスペース作成 |
|  | 設定名 | 値 | 備考 |  | ※dbuser(cloudpack提供)ユーザで作成したユーザではテーブルスペースを作成できないため、「dbuser」でテーブルスペースを作成する |
|  | 個人情報DB用 |  |  |  | create tablespace ntss_db6 OWNER nkk6 LOCATION '/ntss/ntss_db6'; |
|  | 名前 | ntss_db6 | 小文字 |  | create tablespace ntss_index6 OWNER nkk6 LOCATION '/ntss/ntss_index6'; |
|  | オーナー | nkk6 | 個人情報管理ユーザ |  |  |
|  | ロケーション | /ntss/ntss_db6 |  |  |  |
|  | 医療情報DB用 |  |  |  | create tablespace ntss_db5 OWNER nkk5 LOCATION '/ntss/ntss_db5'; |
|  | 名前 | ntss_db5 | 小文字 |  | create tablespace ntss_index5 OWNER nkk5 LOCATION '/ntss/ntss_index5'; |
|  | オーナー | nkk5 | 医療情報管理ユーザ |  |  |
|  | ロケーション | /ntss/ntss_db5 |  |  |  |
|  | 認証DB用 |  |  |  | create tablespace ntss_db4 OWNER nkk4 LOCATION '/ntss/ntss_db4'; |
|  | 名前 | ntss_db4 | 小文字 |  | create tablespace ntss_index4 OWNER nkk4 LOCATION '/ntss/ntss_index4'; |
|  | オーナー | nkk4 | 認証管理ユーザ |  |  |
|  | ロケーション | /ntss/ntss_db4 |  |  |  |
|  | ■データベース　※ログインロールから作成すること |  |  |  | ■データベース作成 |
|  | 設定名 | 値 | 備考 |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d postgres -U nkk6 |
|  | 個人情報DB |  |  |  | create database ntss_db6 WITH OWNER=nkk6 TEMPLATE = template0 ENCODING='UTF-8' LC_COLLATE='C' LC_CTYPE='C' TABLESPACE ntss_db6; |
|  | 名前 | ntss_db6 | 小文字 |  |  |
|  | オーナー | nkk6 | 個人情報管理ユーザ |  |  |
|  | エンコーディング | UTF-8 |  |  |  |
|  | Template | template0 |  |  |  |
|  | テーブル空間 | ntss_db6 | 個人情報DB用テーブル空間 |  |  |
|  | コーレーション | C |  |  |  |
|  | 文字型 | C |  |  |  |
|  | 医療情報DB |  |  |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d postgres -U nkk5 |
|  | 名前 | ntss_db5 | 小文字 |  | create database ntss_db5 WITH OWNER=nkk5 TEMPLATE = template0 ENCODING='UTF-8' LC_COLLATE='C' LC_CTYPE='C' TABLESPACE ntss_db5; |
|  | オーナー | nkk5 | 医療情報管理ユーザ |  |  |
|  | エンコーディング | UTF-8 |  |  |  |
|  | Template | template0 |  |  |  |
|  | テーブル空間 | ntss_db5 | 医療情報DB用テーブル空間 |  |  |
|  | コーレーション | C |  |  |  |
|  | 文字型 | C |  |  |  |
|  | 認証DB |  |  |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d postgres -U nkk4 |
|  | 名前 | ntss_db4 | 小文字 |  | create database ntss_db4 WITH OWNER=nkk4 TEMPLATE = template0 ENCODING='UTF-8' LC_COLLATE='C' LC_CTYPE='C' TABLESPACE ntss_db4; |
|  | オーナー | nkk4 | 認証管理ユーザ |  |  |
|  | エンコーディング | UTF-8 |  |  |  |
|  | Template | template0 |  |  |  |
|  | テーブル空間 | ntss_db4 | 認証DB用テーブル空間 |  |  |
|  | コーレーション | C |  |  |  |
|  | 文字型 | C |  |  |  |
|  | ■スキーマ　※ログインロールから作成すること |  |  |  | ■スキーマ作成 |
|  | 設定名 | 値 | 備考 |  |  |
|  | 個人情報DB |  |  |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d ntss_db6 -U nkk6 |
|  | 名前 | ntss | 小文字 |  | create schema ntss authorization nkk6; |
|  | オーナー | nkk6 | 個人情報管理ユーザ |  | alter user nkk6 set search_path to ntss, public; |
|  | ユーザの検索パス | ntss, public |  |  |  |
|  | 医療情報DB |  |  |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d ntss_db5 -U nkk5 |
|  | 名前 | ntss | 小文字 |  | create schema ntss authorization nkk5; |
|  | オーナー | nkk5 | 医療情報管理ユーザ |  | alter user nkk5 set search_path to ntss, public; |
|  | ユーザの検索パス | ntss, public |  |  |  |
|  | 認証DB |  |  |  | psql -h ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com -d ntss_db4 -U nkk4 |
|  | 名前 | ntss | 小文字 |  | create schema ntss authorization nkk4; |
|  | オーナー | nkk4 | 認証管理ユーザ |  | alter user nkk4 set search_path to ntss, public; |
|  | ユーザの検索パス | ntss, public |  |  |  |
|  | ※「ntss-platform-rds.chzddp07crsf.ap-northeast-1.rds.amazonaws.com」(RDSのエンドポイント)の部分はRDSによって異なる |  |  |  |  |
