# sys_medicine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_medicine`
- Logical name: 標準医薬品マスタ
- Physical name: `sys_medicine`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `standard_no`
- Column count: 36
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 基準番号(ＨＯＴコード) | standard_no | character varying | 13 | 1 |  |  |
|  | 処方用番号(ＨＯＴ７) | prescription_no | character varying | 7 |  |  |  |
|  | 会社識別番号 | company_no | character varying | 2 |  |  |  |
|  | 調剤用番号 | dispensing_no | character varying | 2 |  |  |  |
|  | 物流用番号 | logistics_no | character varying | 2 |  |  |  |
|  | ＪＡＮコード | jan_cd | character varying | 13 |  |  |  |
|  | 薬価基準収載医薬品コード | drug_price_standard_cd | character varying | 12 |  |  |  |
|  | 個別医薬品コード | standard_medicine_cd | character varying | 12 |  |  | mst_medicineのstandard_medicine_cdに格納されるコード |
|  | レセプト電算処理システムコード(1) | receipt_cd_1 | character varying | 9 |  |  |  |
|  | レセプト電算処理システムコード(2) | receipt_cd_2 | character varying | 9 |  |  |  |
|  | 告示名称 | notice_name | character varying | 120 |  |  |  |
|  | 販売名 | sales_name | character varying | 120 |  |  |  |
|  | レセプト電算処理システム医薬品名 | receipt_medicine_name | character varying | 90 |  |  |  |
|  | 規格単位 | standard_unit | character varying | 80 |  |  |  |
|  | 包装形態 | pkg_presentation | character varying | 16 |  |  |  |
|  | 包装単位(数) | pkg_amount | numeric | 12,4 |  |  | 整数部:8桁、小数部:4桁 |
|  | 包装単位(単位) | pkg_unit | character varying | 16 |  |  |  |
|  | 包装総量(数) | pkg_total_amount | numeric | 12,4 |  |  | 整数部:8桁、小数部:4桁 |
|  | 包装総量(単位) | pkg_total_unit | character varying | 16 |  |  |  |
|  | 区分 | usage_category_class | character varying | 1 |  |  | 1 : 内服、2 : 外用、3 : 注射、4 : 歯科 |
|  | 製造会社 | manufacture_company | character varying | 30 |  |  |  |
|  | 販売会社 | sales_company | character varying | 25 |  |  |  |
|  | レコード区分 | record_class | character varying | 1 |  |  | 1 : 新規、2 : 削除、3 : 修正、4 : 中止等 |
|  | 更新年月日 | standard_up_date | character varying | 8 |  |  |  |
|  | 包装数量(数量) | pkg_qty_quantity | numeric | 12,4 |  |  | 整数部:8桁、小数部:4桁 |
|  | 包装数量(単位) | pkg_qty_unit | character varying | 16 |  |  |  |
|  | 包装入数(数量) | pkg_qty_per_carton_quantity | numeric | 12,4 |  |  | 整数部:8桁、小数部:4桁 |
|  | 包装入数(単位) | pkg_qty_per_carton_unit | character varying | 16 |  |  |  |
|  | 指示単位 | unit | character varying |  |  |  |  |
|  | レセ単位 | unit_second | character varying |  |  |  | ※要検討 |
|  | 指示単位換算量 | unit_converted_amount | numeric |  |  |  | 指示単位の換算係数<br>レセ単位での最小数量時の数値、または指示単位にした時の数量を持つ。<br>例：）1瓶（レセ単位）に5ml(指示単位）が入った薬剤の場合<br>指示単位換算量には5を入力する。 |
|  | レセ単位換算量 | unit_converted_amount_second | numeric |  |  |  | レセ単位の換算係数<br>レセ単位での最小時数量を持つ<br>例：）1瓶（レセ単位）に5ml(指示単位)が入った薬剤の場合<br>レセ単位換算量には1を入力する。 |
|  | 指示単位小数部桁数 | unit_decimal_point | integer |  |  |  | 指示単位の小数部桁数 |
|  | レセ単位小数部桁数 | unit_decimal_point_second | integer |  |  |  | レセ単位の小数部桁数 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
