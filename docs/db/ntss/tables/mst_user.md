# mst_user

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_user`
- Logical name: 利用者マスタ
- Physical name: `mst_user`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `user_id`
- Column count: 16
- NOT NULL columns: 1

## Related Config / Notes

- [../config/tmp_log_search_condition.md](../config/tmp_log_search_condition.md)
- [../config/mst_user.md](../config/mst_user.md)
- [../config/sheet.md](../config/sheet.md)
- [../config/mst_user_authentication.md](../config/mst_user_authentication.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 利用者ID（内部用ID） | user_id | bigint |  | 1 |  | 利用者マスタ（mst_personal_user）.利用者ID（内部用ID） |
|  | ユーザー設定 | user_settings | jsonb |  |  |  | ユーザ毎の設定を管理 |
|  | 仮登録フラグ | is_provisional | numeric | 1,0 |  |  | 0 : 本登録、1 : 仮登録 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 患者ID | pat_id | bigint |  |  |  | pat_personal.pat_id<br>在宅透析患者にのみ設定 |
|  | 秘密鍵 | secret_key | character |  |  |  |  |
|  | 秘密キー設定フラグ | is_set_qr_code | numeric | 1,0 |  |  | 0:未設定、１：設定済 |
|  | テンプレートログ | tmp_log_search_condition | jsonb |  |  |  | ログ参照の検索条件<br>'@tmp_log_search_conditionで参考 |
|  | アクセスカード番号 | card_idm | character varying |  |  |  |  |
|  | 個人情報取扱い同意フラグ | is_consent | numeric | 1,0 |  | 0 | FNSiの場合のみ使用 |
|  | 個人情報取扱い同意日時 | consent_date | timestamp(3) |  |  |  | FNSiの場合のみ使用 |
|  | パスワード変更日時 | reg_password_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
