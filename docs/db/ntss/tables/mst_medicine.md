# mst_medicine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_medicine`
- Logical name: 薬剤マスタ
- Physical name: `mst_medicine`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicine_cd`
- Column count: 31
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 薬剤コード | medicine_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な薬剤コード | fn_medicine_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 個別医薬品コード(YJコード) | standard_medicine_cd | character varying | 12 |  |  | 治験薬フラグが「0：治験以外」の場合、必須入力 |
|  | 治験フラグ | is_trial | character varying | 1 |  |  | 0：治験以外、1：治験 |
|  | 薬剤名 | medicine_name | character varying |  |  |  |  |
|  | 省略薬剤名 | medicine_short_name | character varying |  |  |  |  |
|  | 指示単位 | unit | character varying |  |  |  |  |
|  | レセ単位 | unit_second | character varying |  |  |  | ※要検討 |
|  | 薬剤分類コード | class_cd | integer |  |  |  | 薬剤分類マスタ．分類コード |
|  | 注射 | is_shot | character varying | 1 |  |  | 0：注射薬剤以外、1：注射薬剤 |
|  | 使用開始日 | use_start_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 使用終了日 | use_end_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 投薬実施フラグ | is_medicated | character varying | 1 |  |  | 0：なし、1：あり |
|  | 指示単位換算量 | unit_converted_amount | numeric |  |  |  | 指示単位の換算係数<br>レセ単位での最小数量時の数値、または指示単位にした時の数量を持つ。<br>例：）1瓶（レセ単位）に5ml(指示単位）が入った薬剤の場合<br>指示単位換算量には5を入力する。 |
|  | レセ単位換算量 | unit_converted_amount_second | numeric |  |  |  | レセ単位の換算係数<br>レセ単位での最小時数量を持つ<br>例：）1瓶（レセ単位）に5ml(指示単位)が入った薬剤の場合<br>レセ単位換算量には1を入力する。 |
|  | 指示基準量 | anticoagulant_original_quantity | numeric |  |  |  | 1MLあたりの数量算出用。薬剤分類「抗凝固剤」の場合に有効<br>（単位：項目「単位」の設定内容）<br>例：）5ml(ml)に1000単位(指示単位)が入った抗凝固剤の場合、指示基準量には1000を入力する。 |
|  | ML基準量 | after_anticoagulant_quantity | numeric |  |  |  | 1MLあたりの数量算出用。薬剤分類「抗凝固剤」の場合に有効<br>（単位：mL）<br>例：）5ml(ml)に1000単位(指示単位)が入った抗凝固剤の場合、ML基準量には5を入力する。 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 院内コード4 | in_hospital_cd_4 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 換算フラグ | is_exchange | character varying | 1 |  | '0' | 0：換算、1：残量破棄、2：数量1固定 |
|  | 投与タイミングコード | medicate_timing_cd | integer |  |  |  | 投与タイミングマスタの有効選択値 |
|  | 手技コード | procedure_cd | integer |  |  |  | 手技マスタの有効選択値 |
|  | 指示単位小数部桁数 | unit_decimal_point | integer |  |  |  | 指示単位の小数部桁数 |
|  | レセ単位小数部桁数 | unit_decimal_point_second | integer |  |  |  | レセ単位の小数部桁数 |
