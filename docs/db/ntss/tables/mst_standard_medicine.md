# mst_standard_medicine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_standard_medicine`
- Logical name: 標準薬剤マスタ
- Physical name: `mst_standard_medicine`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `=IF(A8="","",A8)&IF(A9="","",","&A9)&IF(A12="","",","&A12)&IF(A15="","",","&A15)&IF(A16="","",","&A16)`
- Column count: 24
- NOT NULL columns: 0

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  | 基準番号(ＨＯＴコード) |  | character varying | 13 |  |  | http://www2.medis.or.jp/hcode/index.html<br>https://www.data-index.co.jp/knowledge/detail1-1.html |
|  | 処方用番号(ＨＯＴ７) |  | character varying | 7 |  |  |  |
|  | 会社識別番号 |  | character varying | 2 |  |  |  |
|  | 調剤用番号 |  | character varying | 2 |  |  |  |
|  | 物流用番号 |  | character varying | 2 |  |  |  |
|  | ＪＡＮコード |  | character varying | 13 |  |  |  |
|  | 薬価基準収載医薬品コード |  | character varying | 12 |  |  |  |
|  | 個別医薬品コード |  | character varying | 12 |  |  |  |
|  | レセプト電算処理システムコード(1) |  | character varying | 9 |  |  |  |
|  | レセプト電算処理システムコード(2) |  | character varying | 9 |  |  |  |
|  | 告示名称 |  | character varying | 120 |  |  |  |
|  | 販売名 |  | character varying | 120 |  |  |  |
|  | レセプト電算処理システム医薬品名 |  | character varying | 90 |  |  |  |
|  | 規格単位 |  | character varying | 80 |  |  |  |
|  | 包装形態 |  | character varying | 16 |  |  |  |
|  | 包装単位数 |  | numeric | 8,4 |  |  |  |
|  | 包装単位単位 |  | character varying | 16 |  |  |  |
|  | 包装総量数 |  | numeric | 8,4 |  |  |  |
|  | 包装総量単位 |  | character varying | 16 |  |  |  |
|  | 区分 |  | character varying | 2 |  |  | 内、外、注、歯 |
|  | 製造会社 |  | character varying | 30 |  |  |  |
|  | 販売会社 |  | character varying | 25 |  |  |  |
|  | レコード区分 |  | character varying | 1 |  |  | 1:新規 2:削除 3:修正 4:中止等 |
|  | 更新年月日 |  | character varying | 8 |  |  |  |
