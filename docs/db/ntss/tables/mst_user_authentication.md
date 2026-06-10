# mst_user_authentication

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_user_authentication`
- Logical name: 利用者マスタ
- Physical name: `mst_user_authentication`
- Prefix group: `master`
- User: `nkk4`
- Tablespace DB: `ntss_db4`
- Tablespace INDEX: `ntss_index4`
- Primary key definition: `user_id`
- Column count: 9
- NOT NULL columns: 3

## Related Config / Notes

- [../config/mst_user_authentication.md](../config/mst_user_authentication.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 利用者ID（内部用ID） | user_id | bigint |  | 1 |  | 利用者マスタ（mst_personal_user）.利用者ID（内部用ID） |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 表示用利用者ID | disp_user_id | character varying | 12 |  |  | 施設コードと表示用利用者IDで一意制約 |
|  | パスワード | user_password | character varying | 75 | 1 |  | 暗号化対象 |
|  | サインイン失敗回数 | failure_cnt | numeric | 3,0 | 1 | 0 |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | パスワード履歴 | user_password_history | jsonb |  |  |  | @mst_user_authentication 参照 |
|  | アクセスカード番号 | card_idm | character varying | 50 |  |  |  |
