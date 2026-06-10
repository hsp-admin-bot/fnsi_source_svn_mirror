# mst_preparation_medicine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_preparation_medicine`
- Logical name: 調製薬剤マスタ
- Physical name: `mst_preparation_medicine`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,preparation_medicine_cd`
- Column count: 22
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 調製薬剤コード | preparation_medicine_cd | character varying | 10 | 1 |  |  |
|  | 調製薬剤名 | preparation_medicine_name | character varying | 80 |  |  |  |
|  | 省略調製薬剤名 | preparation_medicine_name | character varying | 80 |  |  |  |
|  | 薬剤分類コード | class_cd | character varying | 3 |  |  | 薬剤分類マスタ．分類コード |
|  | 単位 | unit | character varying | 20 |  |  |  |
|  | 指示単位 | ind_unit | character varying | 20 |  |  |  |
|  | 薬剤セット数 | medi_set_num | numeric | 3,0 |  | 1 |  |
|  | 有効成分 | active_ingredient | numeric | 6,0 |  |  |  |
|  | 容量 | capacity | numeric | 2,0 |  |  |  |
|  | 投薬実施フラグ | medi_ach_flg | character varying | 1 |  |  |  |
|  | 薬剤情報 | medicine_info | jsonb |  |  |  | [{<br>    "cd": 薬剤コード,<br>    up_date: 薬剤更新日時,<br>    name: 薬剤名,<br>    "value": 薬剤使用量,<br>    "standard_unit": 調製単位,<br>    "medi_use_num": 使用薬剤数<br>}, …] |
|  | 有効成分<br>抗凝固剤換算元数量 |  |  |  |  |  |  |
|  | 容量<br>抗凝固剤換算後数量 |  |  |  |  |  |  |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なセット薬剤コード | fn_set_medicine_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
