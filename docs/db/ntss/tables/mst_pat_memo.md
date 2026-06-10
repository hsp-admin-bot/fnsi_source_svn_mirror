# mst_pat_memo

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_memo`
- Logical name: 患者メモマスタ
- Physical name: `mst_pat_memo`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,pat_memo_no`
- Column count: 8
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 患者メモ番号 | pat_memo_no | smallint |  | 1 |  | 1～20固定 |
|  | タイトル | title | character varying |  |  |  |  |
|  | 内容 | content | character varying |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
