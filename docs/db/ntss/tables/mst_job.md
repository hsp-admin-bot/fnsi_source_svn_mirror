# mst_job

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_job`
- Logical name: 職種マスタ
- Physical name: `mst_job`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `job_cd`
- Column count: 14
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_job.md](../config/mst_job.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 職種コード | job_cd | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 職種名 | job_name | character varying | 40 |  |  | 職種の名前 |
|  | 医師フラグ | is_doctor | character varying | 1 |  | '0' | 0':その他、'1':医師 |
|  | デフォルトメニュー設定 | default_menu_settings | jsonb |  | 1 | '{"initial_menu_function": "005", "default_menu_functions": ["005"]}' | 職種毎の設定を管理 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な職種コード | fn_job_class_cd | numeric |  |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | デフォルト権限 | default_authorized_authorities | character varying | 200 |  |  | 職種のデフォルト権限を管理（カンマ区切りの文字列）<br>設定例：031,043,053 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | デフォルト表示設定 | default_disp_settings | jsonb |  |  |  | 職種のデフォルト表示設定を管理 |
|  | デフォルト通知設定 | default_notification_settings | jsonb |  |  |  | 職種のデフォルト通知設定を管理 |
