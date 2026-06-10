# mst_prescription_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_prescription_set`
- Logical name: 処方セットマスタ
- Physical name: `mst_prescription_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `prescription_set_cd`
- Column count: 10
- NOT NULL columns: 4

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 処方セットコード | prescription_set_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 処方セット名 | prescription_set_name | character varying | 256 | 1 |  |  |
|  | セット情報 | set_info | jsonb | 4 | 1 | []'::jsonb | @ord_prescriptionシートを参照<br><br>※先頭行がRp＋1でない状態も許容、先頭RpなしはRpに"0"を設定 |
|  | 連携コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 連携コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
