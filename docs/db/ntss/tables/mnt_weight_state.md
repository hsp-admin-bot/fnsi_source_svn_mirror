# mnt_weight_state

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_weight_state`
- Logical name: 体重計状態管理
- Physical name: `mnt_weight_state`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `weight_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 体重計管理コード | weight_cd | bigint |  | 1 |  | 体重計マスタ.体重計管理コード |
|  | 接続状態 | is_connect | character varying | 1 |  |  | 0':切断 '1':接続 |
|  | 測定値 | scale_value | numeric | 6,3 |  |  | 単位（kg） |
|  | バーコードリーダー取得値 | barcode_value | character varying | 20 |  |  |  |
|  | カード取得値 | card_read_value | jsonb |  |  |  | ※構成未定 |
|  | カード書き込み内容 | card_write_value | jsonb |  |  |  | ※構成未定 |
|  | カード書き込み結果 | write_result | numeric | 1,0 |  |  | 0:結果待ち 1:成功 -1:失敗 |
|  | 体重値候補リスト | scale_value_list | character varying |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
