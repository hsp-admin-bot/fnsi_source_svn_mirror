# pat_prescription_detail

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_prescription_detail`
- Logical name: 患者処方詳細情報
- Physical name: `pat_prescription_detail`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_id,prescript_no,ctl_no`
- Column count: 12
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_prescription.pat_id |
| 1 | 処方番号 | prescript_no | integer |  | 1 |  | pat_prescription.prescript_no |
| 1 | 管理番号 | ctl_no | smallint |  | 1 |  |  |
|  | 薬剤情報 | medicine_info | jsonb |  |  | E'{"medicine_cd":null,"medicine_update":null,"medicine_name":null}' | 薬剤情報<br>{<br>  "medicine_cd":薬剤マスタ.薬剤コード<br>  "medicine_update":薬剤マスタ.更新日時<br>  "medicine_name":薬剤マスタ.薬剤名<br>} |
|  | 分量 | quantity | numeric | 9,3 |  |  | 1回あたりの服用量 |
|  | 単位 | unit | character varying | 20 |  |  |  |
|  | 用量 | dosage | smallint |  |  |  | 1日あたりの服用回数 |
|  | 用法情報 | take_medicine_info | jsonb |  |  | E'{"take_medicine_cd":null,"take_medicine_update":null,"take_medicine_name":null}' | 用法情報<br>{<br>  "take_medicine_cd":用法マスタ.用法コード<br>  "take_medicine_update":用法マスタ.更新日時<br>  "take_medicine_name":用法マスタ.用法内容<br>} |
|  | 調剤日数 | day_count | smallint |  |  |  | 服用日数 |
|  | 表示順 | disp_order | smallint |  |  |  | 1からの連番 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
