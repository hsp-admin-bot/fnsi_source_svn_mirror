# mst_facility

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_facility`
- Logical name: 施設マスタ
- Physical name: `mst_facility`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd`
- Column count: 17
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 施設名 | facility_name | character varying | 40 | 1 |  |  |
|  | 施設カナ名 | facility_name_kana | character varying | 50 |  |  | ソートする際に使用 |
|  | 都道府県コード | prefectures_cd | character varying | 2 |  |  | 都道府県マスタ.都道府県コード |
|  | 部署符号 | department_cd | character varying | 4 |  |  |  |
|  | 緊急発報メールテンプレート | m_notice_mail_template | character varying | 4000 |  |  |  |
|  | 自動データ収集開始時刻 | auto_gathering_start_time | character varying | 4 |  |  | 「HHMM」形式で格納（00:00～23:59まで） |
|  | 死活監視間隔 | alive_moni_interval | numeric | 8,0 |  | 600 | 秒単位<br>「現在日時-最終確認日時＞監視間隔」となった場合に起動確認要求をデバイスエッジに送信 |
|  | 認証キー | certification_key | character varying | 128 |  |  |  |
|  | 使用可能機能 | use_function | jsonb |  |  |  | 施設で使用出来る機能をjson形式で格納 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 拡張設定 | advanced_settings | jsonb |  |  |  | @advanced_settingsシートで参考 |
|  | 担当営業メールアドレス | sales_email_address | character varying | 255 |  |  |  |
|  | VPNセット | vpn_set | character varying | 1 |  |  | 0:非VPN用URLを表示<br>1:VPN用URLを表示 |
|  | システム利用設定 | system_use_setting | character varying | 1 |  | '1' | '1'：ReMSのみ、'2'：次世代FNのみ、'3'：ReMS+次世代FN |
|  | スケジュール延長除外フラグ | is_schext_exception | character varying | 1 |  | '0' | null:スケジュール延長対象<br>'0':スケジュール延長対象<br>'1':スケジュール延長除外 |
