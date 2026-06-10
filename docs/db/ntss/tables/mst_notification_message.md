# mst_notification_message

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_notification_message`
- Logical name: 通知メッセージマスタ
- Physical name: `mst_notification_message`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `notification_message_cd`
- Column count: 8
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 通知メッセージコード | notification_message_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | メッセージタイトル | title | character varying |  |  |  |  |
|  | メッセージ本文 | content | character varying |  |  |  | "%s"でパラメータ埋め込み位置を指定する。 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
