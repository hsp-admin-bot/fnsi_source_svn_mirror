# mst_standard_course

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_standard_course`
- Logical name: 標準診療科マスタ
- Physical name: `mst_standard_course`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `standard_course_cd`
- Column count: 2
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 標準診療科コード | standard_course_cd | smallserial |  | 1 |  | https://www.mhlw.go.jp/topics/2009/05/dl/tp0521-1a_0053.pdf |
|  | 診療科名 | course_name | character varying |  |  |  |  |
