# mst_bio_moni_frame_pattern

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_bio_moni_frame_pattern`
- Logical name: 生体モニタリングフレームパターンマスタ
- Physical name: `mst_bio_moni_frame_pattern`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,ctl_no`
- Column count: 8
- NOT NULL columns: 6

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
| 1 | 管理番号 | ctl_no | smallint |  | 1 |  |  |
|  | テンプレート名 | template_name | character varying |  | 1 |  |  |
|  | フレーム種別 | frame_type | numeric | 1,0 | 1 |  | 0：一覧、1：詳細 |
|  | フレーム番号 | frame_no | smallint |  | 1 |  | フレームマスタ.フレーム番号 |
|  | 定義情報 | define_info | jsonb |  | 1 |  | 【※1】参照 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
