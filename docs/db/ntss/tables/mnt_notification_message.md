# mnt_notification_message

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_notification_message`
- Logical name: 通知メッセージテーブル
- Physical name: `mnt_notification_message`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `notification_message_no`
- Column count: 7
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mnt_notification_message.md](../config/mnt_notification_message.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 通知メッセージ番号 | notification_message_no | bigserial |  | 1 |  |  |
|  | メッセージ本文 | content | character varying |  |  |  |  |
|  | 付加情報 | additional_info | jsonb |  |  |  | 「@mnt_notification_message」参照 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | 通知定義番号 | notification_no | bigint | 8 |  |  |  |
