# sys_signin_manager

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_signin_manager`
- Logical name: サインイン管理
- Physical name: `sys_signin_manager`
- Prefix group: `system`
- User: `nkk4`
- Tablespace DB: `ntss_db4`
- Tablespace INDEX: `ntss_index4`
- Primary key definition: `terminal_unique_string`
- Column count: 5
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 端末固有文字列 | terminal_unique_string | character varying | 16 | 1 |  | localStorageに保存したもの |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 利用者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
