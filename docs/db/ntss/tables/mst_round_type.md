# mst_round_type

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_round_type`
- Logical name: 種別マスタ
- Physical name: `mst_round_type`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `round_type_cd`
- Column count: 13
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 種別コード | round_type_cd | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 種別名 | round_type_name | character varying | 40 | 1 |  |  |
|  | 内容 | content | character varying |  |  |  |  |
|  | 内容省略フラグ | is_content_omission | character varying | 1 |  | '0' | '0':省略しない、'1':省略する |
|  | 指示コメント転記初期値 | comment_post_default | character varying | 1 |  | '0' | '0'：チェックなし、'1'：チェックあり |
|  | 転記区分初期値 | posting_class_default | character varying | 1 |  | '0' | '0':継続、'1':当日のみ |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 通知対象 | is_notification | character varying | 1 |  | '0' | 0':通知しない、'1':通知する |
|  | 強調表示 | highlighting | character varying | 1 |  | '0' | 0':通常、'1':オレンジ、'2':赤 |
