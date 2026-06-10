# mst_exam_matome

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_exam_matome`
- Logical name: 検査まとめ表
- Physical name: `mst_exam_matome`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `,exam_matome_cd`
- Column count: 37
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  | 変更区分 | update_type | numeric | 1 |  |  | 検査項目マスタ.JLAC10コード |
|  | JLAC10ｺｰﾄﾞ（１5/17桁） | exam_matome_early_cd | character varying | 17 |  |  |  |
| 1 | JLAC10ｺｰﾄﾞ（１７桁） | exam_matome_cd | character varying | 17 | 1 |  |  |
|  | 分析物（拡張） | analytical_material | character varying | 3 |  |  |  |
|  | 分析物（コード） | analytical_material_cd | character varying | 5 |  |  |  |
|  | 分析物（名称） | analytical_material_name | character varying | 64 |  |  |  |
|  | 識別（拡張） | identify | character varying | 3 |  |  |  |
|  | 識別（コード） | identify_cd | numeric | 4 |  |  |  |
|  | 識別（名称） | identify_name | character varying | 64 |  |  |  |
|  | 材料（拡張） | material | character varying | 3 |  |  |  |
|  | 材料（コード） | material_cd | numeric | 3 |  |  |  |
|  | 材料（名称） | material_name | character varying | 64 |  |  |  |
|  | 測定法（拡張） | assay | character varying | 3 |  |  |  |
|  | 測定法（コード） | assay_cd | numeric | 3 |  |  |  |
|  | 測定法（名称） | assay_name | character varying | 64 |  |  |  |
|  | 結果識別（共通）（拡張） | result_recognition_common | character varying | 3 |  |  |  |
|  | 結果識別（共通）（コード） | result_recognition_common_cd | numeric | 5 |  |  |  |
|  | 結果識別（共通）（名称） | result_recognition_common_name | character varying | 64 |  |  |  |
|  | 結果識別（固有）（拡張） | result_recognition_inherent | character varying | 3 |  |  |  |
|  | 結果識別（固有）（名称） | result_recognition_inherent_name | character varying | 64 |  |  |  |
|  | 結果識別検索子（分析物＋識別＋結果） | result_identification_searcher | character varying | 11 |  |  |  |
|  | 標準検査名称 | standard_inspection_name | character varying | 64 |  |  |  |
|  | 参考（結果識別コード） | reference_result_identification_cd | numeric | 2 |  |  |  |
|  | 参考（単位） | reference_unit | character varying | 32 |  |  |  |
|  | 保険内 | insured | character varying | 1 |  |  |  |
|  | 診療行為コード | medical_practice_cd | numeric | 9 |  |  |  |
|  | 診療行為名称１（旧名称） | medical_practice_name1 | character varying | 64 |  |  |  |
|  | 診療行為名称２ | medical_practice_name2 | character varying | 64 |  |  |  |
|  | 点数 | points | numeric | 10 |  |  |  |
|  | 章 | chapter | character varying | 1 |  |  |  |
|  | 区分番号 | category_number | numeric | 3 |  |  |  |
|  | 項番 | item_number | numeric | 2 |  |  |  |
|  | 更新年月日 | update_date | numeric | 8 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) | 29 |  |  |  |
|  | 更新日時 | up_date | timestamp(3) | 29 |  |  |  |
