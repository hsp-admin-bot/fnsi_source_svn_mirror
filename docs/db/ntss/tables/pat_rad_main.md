# pat_rad_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_rad_main`
- Logical name: 患者放射線検査結果
- Physical name: `pat_rad_main`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `rad_result_cd`
- Column count: 21
- NOT NULL columns: 5

## Related Config / Notes

- [../config/pat_rad_main.md](../config/pat_rad_main.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な放射線検査結果コード | rad_result_cd | bigserial |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 登録時放射線検査日時 | reg_rad_date | timestamp(3) |  | 1 |  | 時刻は画面の時刻欄を設定。時刻がNULLの場合は00:00:00で。 |
|  | 登録時放射線検査区分 | reg_order_class | character varying | 1 | 1 | '1' | 1:透析前 2:透析後 0:その他 |
|  | 状況区分 | rad_status | character varying | 1 |  | '0' | '0'：依頼、'1'：結果あり |
|  | 放射線検査依頼セット情報 | order_rad_set_info | jsonb |  |  |  | ※@pat_rad_main参照 |
|  | 連携オーダ番号１ | cop_order_no1 | bigint |  |  |  | 電子カルテとの連携用に付番 |
|  | 連携オーダ番号２ | cop_order_no2 | bigint |  |  |  | 電子カルテとの連携用に付番 |
|  | 依頼変更可否フラグ | is_lock | character varying | 1 |  |  | '0'：変更可(依頼締切前)、'1'：変更不可（依頼締切後） |
|  | 指示者 | ind_user_id | bigint |  |  |  | 指示スタッフID |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 登録スタッフ | reg_staff | bigint |  |  |  | 登録時スタッフID |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 最終更新スタッフ | up_staff | bigint |  |  |  | 最終更新スタッフID |
|  | 指定期間開始日 | rad_from | timestamp(3) |  |  |  |  |
|  | 放射線検査依頼パターン | rad_pattern | bigint |  |  |  |  |
|  | 指定期間終了日 | rad_to | timestamp(3) |  |  |  |  |
|  | 指定曜日 | rad_week | bigint |  |  |  |  |
