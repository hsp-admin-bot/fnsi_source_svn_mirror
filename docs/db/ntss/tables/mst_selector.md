# mst_selector

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_selector`
- Logical name: 選択肢マスタ
- Physical name: `mst_selector`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,master_physical_name`
- Column count: 13
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | マスタ物理名称 | master_physical_name | character varying | 40 | 1 |  |  |
|  | 並び順設定 | order_settings | jsonb |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 【並び順設定の保有イメージ】 |  |  |  |  |  |  |
|  | コード |  |  |  |  |  |  |
|  | 名称 |  |  |  |  |  |  |
|  | Key1 |  |  |  |  |  |  |
|  | Key2 |  |  |  |  |  |  |
|  | Key3 | 使用する側で必要な項目を保持 |  |  |  |  |  |
|  | Key4 | → マスタメンテ側では変更を行わない |  |  |  |  |  |
|  | Key5 | (値が設定されていたら内容を保持する) |  |  |  |  |  |
