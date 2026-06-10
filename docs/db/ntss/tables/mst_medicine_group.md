# mst_medicine_group

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_medicine_group`
- Logical name: 薬剤グループマスタ
- Physical name: `mst_medicine_group`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicine_group_cd`
- Column count: 13
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な薬剤マスタ | medicine_group_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 薬剤グループ名 | medicine_group_name | character varying |  |  |  |  |
|  | 登録薬剤情報 | reg_medicine_info | jsonb |  |  |  | [<br>{"cd": 薬剤CD,<br>"del": 削除フラグ, <br>"update": 更新日時, <br>"classCd": 分類Cd, <br>"con_val": 交換値, <br>"medi_flg": 薬剤フラグ<br>},<br>….<br>] |
|  | 単位 | medicine_group_unit | character varying |  |  |  |  |
|  | 週間投与フラグ | week_flg | character varying | 1 |  |  |  |
|  | グラフ上限 | graph_upper | numeric | 8,2 |  |  |  |
|  | グラフ下限 | graph_lower | numeric | 8,2 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な薬剤グループコード | fn_medicine_group_cd | character varying |  |  |  |  |
