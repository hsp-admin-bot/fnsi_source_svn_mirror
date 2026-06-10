# mst_standard_disease

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_standard_disease`
- Logical name: 標準病名マスタ
- Physical name: `mst_standard_disease`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `standard_disease_cd`
- Column count: 8
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 標準病名コード | standard_disease_cd | serial |  | 1 |  | http://www2.medis.or.jp/stdcd/byomei/index.html |
|  | 病名 | disease_name | character varying |  |  |  |  |
|  | 病名カナ | disease_name_kana | character varying |  |  |  |  |
|  | 傷病名省略名 | disease_short_name | character varying |  |  |  |  |
|  | ICD10 | icd_10_class_name | character varying |  |  |  |  |
|  | ICD10複数分類コード | icd_10_class_cd | character varying |  |  |  |  |
|  | ICD10-2013 | icd_10_2013_class_name | character varying |  |  |  |  |
|  | ICD10-2013複数分類コード | icd_10_2013_class_cd | character varying |  |  |  |  |
