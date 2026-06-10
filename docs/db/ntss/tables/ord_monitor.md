# ord_monitor

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_monitor`
- Logical name: 実績モニタデータ
- Physical name: `ord_monitor`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ord_monitor_ctl_no`
- Column count: 8
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 実績モニタデータ管理番号 | ord_monitor_ctl_no | bigserial |  | 1 |  | シーケンス使用 |
|  | 生体モニタリング管理番号 | bio_moni_ctl_no | bigint |  |  |  | mni_monitor.bio_moni_ctl_no |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | ord_main.ord_no |
|  | モニタデータ | monitor_data | jsonb |  |  |  | 「@mni_monitor」シート参照(新通信データ) |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 発生日時 | occur_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
