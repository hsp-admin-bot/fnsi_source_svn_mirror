# mst_take_medicine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_take_medicine`
- Logical name: 用法・用語マスタ
- Physical name: `mst_take_medicine`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `take_medicine_cd`
- Column count: 10
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 用法用語マスタコード | take_medicine_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | リスト種別 | list_class | character varying | 2 | 1 |  | 01：調剤指示リスト<br>10：内服用法リスト<br>11：内服用法詳細リスト<br>20：外用用法リスト<br>21：外用用法詳細リスト<br>22：部位リスト<br>23：左右リスト<br>30：内服頓服用法リスト<br>40：外用頓服用法リスト<br>99：用語リスト |
|  | リスト名 | list_name | character varying |  |  |  |  |
|  | リスト選択肢 | list_details | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  |  | fn_take_medicine_cd | varchar | 3 |  |  |  |
