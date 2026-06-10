# mst_frame_define

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_frame_define`
- Logical name: フレーム定義マスタ
- Physical name: `mst_frame_define`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `frame_no`
- Column count: 5
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | フレーム番号 | frame_no | smallint |  | 1 |  |  |
|  | フレーム種別 | frame_type | numeric | 1,0 | 1 |  | 0：一覧、1：詳細 |
|  | フレーム定義 | frame_define | jsonb |  | 1 |  | フレーム定義情報（タグ情報）を格納 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
