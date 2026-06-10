# mst_medicine_mix

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_medicine_mix`
- Logical name: 調製薬剤マスタ
- Physical name: `mst_medicine_mix`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicine_mix_cd`
- Column count: 24
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 調整薬剤コード | medicine_mix_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意なセット薬剤名称コード | fn_set_medicine_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 調整薬剤名 | medicine_mix_name | character varying |  |  |  |  |
|  | 省略調整薬剤名 | medicine_mix_short_name | character varying |  |  |  |  |
|  | 薬剤分類コード | class_cd | integer |  |  |  |  |
|  | 指示単位 | unit | character varying |  |  |  |  |
|  | 指示単位基準量 | amount_unit | numeric |  |  |  |  |
|  | mL単位基準量 | amount_ml | numeric |  |  |  |  |
|  | 調整薬剤情報 | mix_info | jsonb |  |  |  | {<br>  solvent：数量固定（0：なし、1：固定）<br>  cd：薬剤マスタ.薬剤コード<br>  amount：数量<br>  unit：薬剤マスタ.指示単位<br>},… |
|  | 注射 | is_shot | character varying | 1 |  |  |  |
|  | 投与実施フラグ | is_medicated | character varying | 1 |  |  |  |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 投与タイミングコード | medicate_timing_cd | integer |  |  |  | 投与タイミングマスタの有効選択値 |
|  | 手技コード | procedure_cd | integer |  |  |  | 手技マスタの有効選択値 |
|  | 指示単位小数部桁数 | unit_decimal_point | integer |  |  |  | 指示単位の小数部桁数 |
|  | 薬剤セット数 | medicine_set_num | integer |  |  |  |  |
|  | レセ単位 | unit_second | character varying |  |  |  |  |
