# pat_insurance

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_insurance`
- Logical name: 保険情報
- Physical name: `pat_insurance`
- Prefix group: `patient`
- User: `nkk6`
- Tablespace DB: `ntss_db6`
- Tablespace INDEX: `ntss_index6`
- Primary key definition: `insurance_cd`
- Column count: 26
- NOT NULL columns: 3

## Related Config / Notes

- [../config/insu_info.md](../config/insu_info.md)
- [../config/insu_pub_info.md](../config/insu_pub_info.md)
- [../config/insu_set_info.md](../config/insu_set_info.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な保険情報コード | insurance_cd | bigserial |  | 1 |  | シーケンス |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 登録番号 | ctl_no | bigint |  |  |  | 並び順 |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 保険リスト情報 | insu_class | integer |  |  |  | 保険区分（０：保険１：公費２：セット３：自費） |
|  | 保険名称 | insu_name | character varying |  |  |  |  |
|  | 保険略称 | insu_name_short | character varying | 4 |  |  |  |
|  | 開始日 | start_date | timestamp(3) |  |  |  |  |
|  | 終了日 | end_date | timestamp(3) |  |  |  |  |
|  | 確認日 | check_date | timestamp(3) |  |  |  |  |
|  | 保険情報 | insu_info | jsonb |  |  |  | ＠insu_info参考<br>保険区分が「０：保険」の場合、情報設定<br>上記以外の場合、NULLに設定 |
|  | 公費情報 | insu_pub_info | jsonb |  |  |  | ＠insu_pub_info参考<br>保険区分が「１：公費」の場合、情報設定<br>上記以外の場合、NULLに設定 |
|  | セット情報 | insu_set_info | jsonb |  |  |  | ＠insu_set_info参考<br>保険区分が「２：セット」の場合、情報設定<br>上記以外の場合、NULLに設定 |
|  | 連携時に受信したコード | coop_code | character varying | 12 |  |  |  |
|  | 電カル連携フラグ | is_coop | character varying | 1 |  |  | 0: 手で入力<br>1 :外部連携登録 |
|  | 主保険フラグ | is_selected | character varying | 1 |  |  | 1:主保険. 0:主保険ではない |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | (旧)更新日時 | old_up_date | timestamp(3) |  |  |  |  |
|  | 自費情報 | insu_self_info | jsonb |  |  |  | {<br>insu_self_name String 自費名称<br>}<br>保険区分が「３：自費」の場合、情報設定<br>上記以外の場合、NULLに設定 |
|  | 保険メモ１ | memo1 | character varying |  |  |  |  |
|  | 保険メモ2 | memo2 | character varying |  |  |  |  |
|  | FNW+で管理する施設内の一意な職種コード | fn_ctl_no | character varying | 1 |  |  |  |
