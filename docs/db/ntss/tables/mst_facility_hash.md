# mst_facility_hash

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_facility_hash`
- Logical name: 施設マスタハッシュ
- Physical name: `mst_facility_hash`
- Prefix group: `master`
- User: `nkk4`
- Tablespace DB: `ntss_db4`
- Tablespace INDEX: `ntss_index4`
- Primary key definition: `facility_cd`
- Column count: 11
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 外部キー制約（施設マスタ.施設コード） |
|  | ハッシュ値 | hash_value | character varying | 100 | 1 |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | システム利用設定 | system_use_setting | character varying | 1 |  | '1' | '1'：ReMSのみ、'2'：次世代FNのみ、'3'：ReMS+次世代FN |
|  | アカウントロック設定 | account_lock_setting | character varying | 1 |  | '1' |  |
|  | サインイン失敗回数 | failure_cnt | numeric | 3,0 |  | 5 |  |
|  | 2要素認証失敗回数 | otp_failure_cnt | numeric | 3,0 |  | 5 |  |
|  | URLサインイン設定 | url_signin | character varying | 1 |  |  | sys_facilitysetting.ctl_no = '2001' |
|  | URLサインイン秘密鍵 | url_signin_secretkey | character varying |  |  |  | sys_facilitysetting.ctl_no = '2002' |
|  | 值 | value | character varying | 3 |  |  |  |
