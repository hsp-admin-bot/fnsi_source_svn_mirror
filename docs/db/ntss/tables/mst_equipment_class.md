# mst_equipment_class

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_equipment_class`
- Logical name: 医療材料分類マスタ
- Physical name: `mst_equipment_class`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `class_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 分類コード | class_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な分類コード | fn_class_cd | character varying | 3 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 分類名称 | class_name | character varying |  |  |  |  |
|  | 分類区分 | class_type | numeric | 2 |  |  | 0：該当なし、1：血液回路、2：穿刺針(SN以外)、3：穿刺針(SN)、4：吸着カラム、5：吸着器、6：分離器<br>※マスタ編集画面での編集は可能とする。<br>※区分変更時はメッセージ通知を行う。<br>（既に登録されている指示に影響する旨を通知する。）<br>※条件送信時に治療条件と区分の整合性が取れているかチェックする必要がある。 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 編集可否フラグ | is_editable | character varying | 1 |  | '1' | '0':編集不可、'1':編集可 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
