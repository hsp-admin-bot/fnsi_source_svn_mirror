# mst_equipment

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_equipment`
- Logical name: 医療材料マスタ
- Physical name: `mst_equipment`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `equipment_cd`
- Column count: 19
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 医療材料コード | equipment_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な医療材料コード | fn_equipment_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 標準医療材料コード | standard_equipment_cd | character varying |  |  |  | JANコード、JMDNコードなどを登録予定<br>治験フラグが「0：治験以外」の場合、必須入力 |
|  | 治験フラグ | is_trial | character varying | 1 |  |  | 0：治験以外、1：治験 |
|  | 医療材料名 | equipment_name | character varying |  |  |  |  |
|  | 省略医療材料名 | equipment_short_name | character varying |  |  |  |  |
|  | 医療材料分類コード | class_cd | integer |  |  |  | 医療材料分類マスタ．分類コード |
|  | 単位 | unit | character varying |  |  |  |  |
|  | 使用開始日 | use_start_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 使用終了日 | use_end_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 院内コード4 | in_hospital_cd_4 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
